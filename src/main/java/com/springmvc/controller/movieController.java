package com.springmvc.controller;

import com.springmvc.domain.movie;
import com.springmvc.service.externalMovieApiService;
import com.springmvc.service.movieService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession; // HttpSession 임포트 확인

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.List;

@Controller
public class movieController {

    private static final Logger logger = LoggerFactory.getLogger(movieController.class);

    private static final String UPLOAD_DIRECTORY_RELATIVE = "/resources/images/movies/";

    private final movieService movieService;
    private final externalMovieApiService externalMovieApiService;

    @Autowired
    public movieController(movieService movieService, externalMovieApiService externalMovieApiService) {
        this.movieService = movieService;
        this.externalMovieApiService = externalMovieApiService;
    }

    // --- 역할 기반 접근 제어 헬퍼 메서드 ---
    // 세션에서 "userRole" 값을 가져와 "ADMIN"인지 확인합니다.
    // 세션에 "userRole"이 없거나 "ADMIN"이 아니면 false를 반환합니다.
    private boolean isAdmin(HttpSession session) {
        String userRole = (String) session.getAttribute("userRole");
        return "ADMIN".equals(userRole);
    }
    
    // --- 기본 영화 관리 (CRUD) 기능 ---

    // 1. 새 영화 등록 폼 (Create Form)
    // GET /PreWatch/movies/new
    @GetMapping("/movies/new")
    public String createForm(Model model, HttpSession session) {
        // ⭐ 관리자만 접근 가능
        if (!isAdmin(session)) {
            logger.warn("[GET /movies/new] 권한 없음: 비관리자 접근 시도.");
            return "redirect:/accessDenied"; // 권한 없음 페이지로 리다이렉트
        }
        logger.info("[GET /movies/new] 새 영화 등록 폼 요청.");
        model.addAttribute("movie", new movie());
        model.addAttribute("userRole", session.getAttribute("userRole")); // JSP에 역할 전달
        return "movie/form";
    }

    // 2. 영화 등록 처리 (Create Process)
    // POST /PreWatch/movies
    @PostMapping("/movies")
    public String create(@ModelAttribute movie movie,
                         @RequestParam("posterImage") MultipartFile posterImage,
                         HttpServletRequest request, HttpSession session) {
        // ⭐ 관리자만 접근 가능
        if (!isAdmin(session)) {
            logger.warn("[POST /movies] 권한 없음: 비관리자 영화 등록 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies] 새 영화 등록 요청: 제목 = {}", movie.getTitle());

        if (posterImage != null && !posterImage.isEmpty()) {
            try {
                String realUploadPath = request.getSession().getServletContext().getRealPath(UPLOAD_DIRECTORY_RELATIVE);
                File uploadDir = new File(realUploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                    logger.debug("업로드 디렉토리 생성: {}", realUploadPath);
                }

                String originalFileName = posterImage.getOriginalFilename();
                String fileExtension = "";
                if (originalFileName != null && originalFileName.contains(".")) {
                    fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                }
                String savedFileName = UUID.randomUUID().toString() + fileExtension;
                Path filePath = Paths.get(realUploadPath, savedFileName);

                Files.copy(posterImage.getInputStream(), filePath);
                logger.info("포스터 이미지 저장 성공: {}", filePath.toString());

                movie.setPosterPath(UPLOAD_DIRECTORY_RELATIVE + savedFileName);

            } catch (IOException e) {
                logger.error("포스터 이미지 업로드 실패: {}", e.getMessage(), e);
                movie.setPosterPath(null);
            }
        } else {
            logger.info("[POST /movies] 업로드된 포스터 이미지 없음.");
            movie.setPosterPath(null);
        }

        movieService.save(movie);
        logger.info("영화 '{}' DB에 저장 완료.", movie.getTitle());
        return "redirect:/movies";
    }

    // 3. 영화 상세 (Read One)
    // GET /PreWatch/movies/{id}
    @GetMapping("/movies/{id}")
    public String detail(@PathVariable Long id, Model model, HttpSession session) {
        logger.info("[GET /movies/{}] 영화 상세 정보 요청: ID = {}", id, id);
        movie movie = movieService.findById(id);

        if (movie == null) {
            logger.warn("[GET /movies/{}] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
            return "redirect:/movies?error=notFound";
        }

        model.addAttribute("movie", movie);
        model.addAttribute("userRole", session.getAttribute("userRole")); // JSP에 역할 전달
        logger.debug("[GET /movies/{}] movieService.findById({}) 호출 완료.", id, id);

        return "movie/detailPage";
    }

    // 4. 영화 목록 (Read All)
    // GET /PreWatch/movies 또는 GET /PreWatch/movies/
    @GetMapping({"/movies", "/movies/"})
    public String list(Model model, HttpSession session) {
        logger.info("[GET /movies] 영화 목록 요청이 들어왔습니다.");
        model.addAttribute("movies", movieService.findAll());
        model.addAttribute("userRole", session.getAttribute("userRole")); // JSP에 역할 전달
        logger.debug("[GET /movies] movieService.findAll() 호출 완료.");
        return "movie/list";
    }


    // 5. 영화 수정 폼 (Update Form)
    // GET /PreWatch/movies/{id}/edit
    @GetMapping("/movies/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, HttpSession session) {
        // ⭐ 관리자만 접근 가능
        if (!isAdmin(session)) {
            logger.warn("[GET /movies/{}/edit] 권한 없음: 비관리자 접근 시도.", id);
            return "redirect:/accessDenied";
        }
        logger.info("[GET /movies/{}/edit] 영화 수정 폼 요청: ID = {}", id, id);
        movie movie = movieService.findById(id);

        if (movie == null) {
            logger.warn("[GET /movies/{}/edit] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
            return "redirect:/movies?error=notFound";
        }

        model.addAttribute("movie", movie);
        model.addAttribute("userRole", session.getAttribute("userRole")); // JSP에 역할 전달
        return "movie/form";
    }

    // 6. 영화 수정 처리 (Update Process)
    // POST /PreWatch/movies/{id}/edit
    @PostMapping("/movies/{id}/edit")
    public String update(@PathVariable Long id,
                         @ModelAttribute movie movie,
                         @RequestParam("posterImage") MultipartFile posterImage,
                         HttpServletRequest request, HttpSession session) {
        // ⭐ 관리자만 접근 가능
        if (!isAdmin(session)) {
            logger.warn("[POST /movies/{}/edit] 권한 없음: 비관리자 영화 업데이트 시도.", id);
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/{}/edit] 영화 업데이트 요청: ID = {}, 제목 = {}", id, movie.getTitle());
        movie.setId(id);

        movie existingMovie = movieService.findById(id);
        String oldPosterPath = existingMovie != null ? existingMovie.getPosterPath() : null;

        if (posterImage != null && !posterImage.isEmpty()) {
            try {
                String realUploadPath = request.getSession().getServletContext().getRealPath(UPLOAD_DIRECTORY_RELATIVE);
                File uploadDir = new File(realUploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                if (oldPosterPath != null && !oldPosterPath.startsWith("http://") && !oldPosterPath.startsWith("https://")) {
                    Path oldFilePath = Paths.get(request.getSession().getServletContext().getRealPath(oldPosterPath));
                    if (Files.exists(oldFilePath)) {
                        Files.delete(oldFilePath);
                        logger.info("기존 포스터 이미지 삭제 성공: {}", oldPosterPath);
                    }
                }

                String originalFileName = posterImage.getOriginalFilename();
                String fileExtension = "";
                if (originalFileName != null && originalFileName.contains(".")) {
                    fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                }
                String savedFileName = UUID.randomUUID().toString() + fileExtension;
                Path filePath = Paths.get(realUploadPath, savedFileName);

                Files.copy(posterImage.getInputStream(), filePath);
                logger.info("새로운 포스터 이미지 저장 성공: {}", filePath.toString());
                movie.setPosterPath(UPLOAD_DIRECTORY_RELATIVE + savedFileName);

            } catch (IOException e) {
                logger.error("포스터 이미지 업데이트 실패: {}", e.getMessage(), e);
                movie.setPosterPath(oldPosterPath);
            }
        } else {
            logger.info("[POST /movies/{}/edit] 새로운 포스터 이미지 업로드 없음. 기존 경로 유지.", id);
            movie.setPosterPath(oldPosterPath);
        }

        movieService.update(movie);
        logger.info("영화 '{}' 업데이트 완료.", movie.getTitle());
        return "redirect:/movies";
    }

    // 7. 영화 삭제 (Delete)
    // POST /PreWatch/movies/{id}/delete
    @PostMapping("/movies/{id}/delete")
    public String delete(@PathVariable Long id, HttpServletRequest request, HttpSession session) {
        // ⭐ 관리자만 접근 가능
        if (!isAdmin(session)) {
            logger.warn("[POST /movies/{}/delete] 권한 없음: 비관리자 영화 삭제 시도.", id);
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/{}/delete] 영화 삭제 요청: ID = {}", id, id);

        movie movieToDelete = movieService.findById(id);
        if (movieToDelete != null && movieToDelete.getPosterPath() != null) {
            if (!movieToDelete.getPosterPath().startsWith("http://") && !movieToDelete.getPosterPath().startsWith("https://")) {
                try {
                    String realPath = request.getSession().getServletContext().getRealPath(movieToDelete.getPosterPath());
                    Path filePath = Paths.get(realPath);
                    if (Files.exists(filePath)) {
                        Files.delete(filePath);
                        logger.info("삭제할 영화의 포스터 이미지 파일 삭제 완료: {}", realPath);
                    }
                } catch (IOException e) {
                    logger.error("영화 삭제 시 포스터 이미지 파일 삭제 실패: {}", e.getMessage(), e);
                }
            } else {
                logger.debug("API 이미지이거나 포스터 경로가 없어 파일 삭제 스킵: {}", movieToDelete.getPosterPath());
            }
        } else {
            logger.debug("삭제할 영화가 없거나 포스터 경로가 없어 파일 삭제 스kip.");
        }

        movieService.delete(id);
        logger.info("영화 ID {} 삭제 완료.", id);
        return "redirect:/movies";
    }

    // --- API 연동 기능 ---

    @GetMapping("/movies/search-api")
    public String searchApiMoviesPage(@RequestParam(value = "query", required = false) String query, Model model, HttpSession session) {
        // ⭐ 관리자만 접근 가능
        if (!isAdmin(session)) {
            logger.warn("[GET /movies/search-api] 권한 없음: 비관리자 API 검색 페이지 접근 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[GET /movies/search-api] API 영화 검색 페이지 또는 검색 결과 요청. 쿼리: {}", query);
        if (query != null && !query.trim().isEmpty()) {
            List<movie> searchResults = externalMovieApiService.searchMoviesByKeyword(query);
            model.addAttribute("apiMovies", searchResults);
            model.addAttribute("searchPerformed", true);
            model.addAttribute("query", query);
        } else {
            model.addAttribute("searchPerformed", false);
        }
        model.addAttribute("userRole", session.getAttribute("userRole")); // JSP에 역할 전달
        return "movie/apiSearchPage";
    }


    @GetMapping("/search") // 이 경로는 헤더 검색창에서 사용되며, API 검색 페이지로 연결됩니다.
    public String searchMoviesFromHeader(@RequestParam(value = "query", required = false) String query, Model model, HttpSession session) {
        logger.info("[GET /search] 헤더 검색 요청. 쿼리: {}", query);
        // 이 기능은 모든 사용자가 접근 가능하도록 유지
        if (query != null && !query.trim().isEmpty()) {
            List<movie> searchResults = externalMovieApiService.searchMoviesByKeyword(query);
            model.addAttribute("apiMovies", searchResults);
            model.addAttribute("searchPerformed", true);
            model.addAttribute("query", query);
        } else {
            model.addAttribute("searchPerformed", false);
        }
        model.addAttribute("userRole", session.getAttribute("userRole")); // JSP에 역할 전달
        return "movie/apiSearchPage"; // API 검색 결과를 보여줄 JSP 페이지
    }


    @PostMapping("/movies/import-api-detail")
    public String importApiMovieDetail(@RequestParam("imdbId") String imdbId, Model model, HttpSession session) {
        // ⭐ 관리자만 접근 가능
        if (!isAdmin(session)) {
            logger.warn("[POST /movies/import-api-detail] 권한 없음: 비관리자 API 영화 등록 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/import-api-detail] API에서 영화 상세 정보 가져와 등록 요청: imdbID = {}", imdbId);

        movie movieFromApi = externalMovieApiService.getMovieFromApi(imdbId);

        if (movieFromApi != null) {
            movieService.save(movieFromApi);
            logger.info("API 영화 '{}' (ID: {}) DB에 성공적으로 등록.", movieFromApi.getTitle(), movieFromApi.getApiId());
            return "redirect:/movies?status=registered"; // 등록 후 목록 페이지로 리다이렉트
        } else {
            logger.warn("[POST /movies/import-api-detail] imdbID '{}'에 해당하는 영화 정보를 API에서 찾을 수 없습니다.", imdbId);
            model.addAttribute("errorMessage", "영화 상세 정보를 찾을 수 없습니다.");
            return "redirect:/search?error=detailNotFound"; // 실패 시 검색 페이지로 돌아가 에러 메시지 표시
        }
    }

    // 권한 없음 페이지 매핑
    @GetMapping("/accessDenied")
    public String accessDenied() {
        return "accessDenied"; // accessDenied.jsp
    }
}