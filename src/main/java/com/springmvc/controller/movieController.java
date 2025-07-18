/*
    파일명: movieController.java
    설명:
        이 class는 영화(movie) 관련 기능을 처리하는 컨트롤러입니다.
        영화의 CRUD (생성, 조회, 수정, 삭제) 기능과 외부 API 연동을 통한 영화 검색 및 등록 기능을 제공합니다.
        관리자(`ADMIN`) 역할에 따른 접근 제어를 수행합니다.

    목적:
        관리자와 일반 사용자 모두에게 영화 정보(조회, 검색)를 제공하고, 관리자에게는 영화 데이터 관리 기능을 제공하기 위함.

*/

package com.springmvc.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.springmvc.domain.movie;
import com.springmvc.service.externalMovieApiService;
import com.springmvc.service.movieService;

@Controller
public class movieController {

    private static final Logger logger = LoggerFactory.getLogger(movieController.class); // Logger 객체 초기화

    // 포스터 이미지 업로드될 상대 경로. 웹 애플리케이션의 `/resources/images/movies/` 폴더에 해당.
    private static final String UPLOAD_DIRECTORY_RELATIVE = "/resources/images/movies/";

    private final movieService movieService;               // movieService 주입
    private final externalMovieApiService externalMovieApiService; // externalMovieApiService 주입

    // 생성자를 통한 의존성 주입: 필요한 서비스 빈들을 Spring 컨테이너로부터 주입받음.
    @Autowired
    public movieController(movieService movieService, externalMovieApiService externalMovieApiService) {
        this.movieService = movieService;
        this.externalMovieApiService = externalMovieApiService;
    }

    // isAdmin 헬퍼 메서드: 세션에서 "userRole"을 가져와 현재 사용자가 "ADMIN"인지 확인.
    // 목적: 관리자 전용 기능 접근 제어
    private boolean isAdmin(HttpSession session) {
        String userRole = (String) session.getAttribute("userRole");
        return "ADMIN".equals(userRole);
    }

    // --- Create ---
    // createForm 메서드: "/movies/new" 경로에 대한 GET 요청 처리
    // 목적: 관리자가 새 영화 정보를 입력할 폼 제공.
    @GetMapping("/movies/new")
    public String createForm(Model model, HttpSession session) {
        if (!isAdmin(session)) { // 관리자 권한 확인
            logger.warn("[GET /movies/new] 권한 없음: 비관리자 접근 시도.");
            return "redirect:/accessDenied"; // 권한 없으면 리다이렉트
        }
        logger.info("[GET /movies/new] 새 영화 등록 폼 요청.");
        model.addAttribute("movie", new movie()); // 빈 movie 객체 추가
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "movie/form"; // "movie/form.jsp" 뷰 반환
    }

    // create 메서드: "/movies" 경로에 대한 POST 요청 처리
    // 목적: 관리자가 입력한 새 영화 정보와 포스터 이미지를 DB에 저장.
    @PostMapping("/movies")
    public String create(@ModelAttribute movie movie,
                         @RequestParam("posterImage") MultipartFile posterImage,
                         HttpServletRequest request, HttpSession session) {
        if (!isAdmin(session)) { // 관리자 권한 확인
            logger.warn("[POST /movies] 권한 없음: 비관리자 영화 등록 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies] 새 영화 등록 요청: 제목 = {}", movie.getTitle());

        // 포스터 이미지 업로드 처리
        if (posterImage != null && !posterImage.isEmpty()) {
            try {
                String realUploadPath = request.getSession().getServletContext().getRealPath(UPLOAD_DIRECTORY_RELATIVE);
                File uploadDir = new File(realUploadPath);
                if (!uploadDir.exists()) { uploadDir.mkdirs(); }

                String originalFileName = posterImage.getOriginalFilename();
                String fileExtension = "";
                if (originalFileName != null && originalFileName.contains(".")) {
                    fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                }
                String savedFileName = UUID.randomUUID().toString() + fileExtension;
                Path filePath = Paths.get(realUploadPath, savedFileName);

                Files.copy(posterImage.getInputStream(), filePath);
                logger.info("포스터 이미지 저장 성공: {}", filePath.toString());
                movie.setPosterPath(UPLOAD_DIRECTORY_RELATIVE + savedFileName); // 상대 경로 설정
            } catch (IOException e) {
                logger.error("포스터 이미지 업로드 실패: {}", e.getMessage(), e);
                movie.setPosterPath(null); // 실패 시 경로 null
            }
        } else {
            logger.info("[POST /movies] 업로드된 포스터 이미지 없음.");
            movie.setPosterPath(null); // 이미지 없으면 null
        }

        movieService.save(movie); // 영화 정보 DB 저장 (Create)
        logger.info("영화 '{}' DB에 저장 완료.", movie.getTitle());
        return "redirect:/movies"; // 영화 목록으로 리다이렉트
    }

    // importApiMovieDetail 메서드: "/movies/import-api-detail" 경로에 대한 POST 요청 처리
    // 목적: 외부 API에서 가져온 영화 상세 정보를 우리 DB에 등록 (관리자 전용).
    @PostMapping("/movies/import-api-detail")
    public String importApiMovieDetail(@RequestParam("imdbId") String imdbId, Model model, HttpSession session) {
        if (!isAdmin(session)) { // 관리자 권한 확인
            logger.warn("[POST /movies/import-api-detail] 권한 없음: 비관리자 API 영화 등록 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/import-api-detail] API에서 영화 상세 정보 가져와 등록 요청: imdbID = {}", imdbId);

        movie movieFromApi = externalMovieApiService.getMovieFromApi(imdbId); // 외부 API에서 상세 정보 가져옴 

        if (movieFromApi != null) {
            movieService.save(movieFromApi); // API에서 가져온 영화 정보를 DB에 저장 (Create)
            logger.info("API 영화 '{}' (ID: {}) DB에 성공적으로 등록.", movieFromApi.getTitle(), movieFromApi.getApiId());
            return "redirect:/movies?status=registered"; // 등록 성공 후 리다이렉트, 상태 메시지 전달
        } else {
            logger.warn("[POST /movies/import-api-detail] imdbID '{}'에 해당하는 영화 정보를 API에서 찾을 수 없습니다.", imdbId);
            model.addAttribute("errorMessage", "영화 상세 정보를 찾을 수 없습니다.");
            return "redirect:/search?error=detailNotFound"; // 실패 시 검색 페이지로 리다이렉트, 에러 메시지 전달
        }
    }

    // --- Read ---
    // detail 메서드: "/movies/{id}" 경로에 대한 GET 요청 처리
    // 목적: 특정 영화의 상세 정보 보여줌. (Read(one) from DB)
    @GetMapping("/movies/{id}")
    public String detail(@PathVariable Long id, Model model, HttpSession session) {
        logger.info("[GET /movies/{}] 영화 상세 정보 요청: ID = {}", id, id);
        movie movie = movieService.findById(id); // 영화 정보 조회 (Read - one from DB)

        if (movie == null) {
            logger.warn("[GET /movies/{}] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
            return "redirect:/movies?error=notFound"; // 영화 없으면 에러와 함께 리다이렉트
        }

        model.addAttribute("movie", movie); // 조회된 movie 객체 추가
        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("[GET /movies/{}] movieService.findById({}) 호출 완료.", id, id);

        return "movie/detailPage"; // "movie/detailPage.jsp" 뷰 반환
    }

    // list 메서드: "/movies" 또는 "/movies/" 경로에 대한 GET 요청 처리
    // 목적: 모든 등록된 영화 목록 보여줌 (관리자 대시보드 역할 겸함). (Read(all) from DB)
    @GetMapping({"/movies", "/movies/"})
    public String list(Model model, HttpSession session) {
        logger.info("[GET /movies] 영화 목록 요청이 들어왔습니다.");
        model.addAttribute("movies", movieService.findAll()); // 모든 영화 목록 조회 및 추가 (Read - all from DB)
        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("[GET /movies] movieService.findAll() 호출 완료.");
        return "movie/list"; // "movie/list.jsp" 뷰 반환
    }

    // searchApiMoviesPage 메서드: "/movies/search-api" 경로에 대한 GET 요청 처리
    // 목적: 외부 API를 통해 영화를 검색할 수 있는 페이지를 보여주거나 검색 결과를 표시 (관리자 전용). (Read(some) from API)
    @GetMapping("/movies/search-api")
    public String searchApiMoviesPage(@RequestParam(value = "query", required = false) String query, Model model, HttpSession session) {
        if (!isAdmin(session)) { // 관리자 권한 확인
            logger.warn("[GET /movies/search-api] 권한 없음: 비관리자 API 검색 페이지 접근 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[GET /movies/search-api] API 영화 검색 페이지 또는 검색 결과 요청. 쿼리: {}", query);
        if (query != null && !query.trim().isEmpty()) { // 검색 쿼리가 유효한 경우
            List<movie> searchResults = externalMovieApiService.searchMoviesByKeyword(query); // 외부 API 검색 (Read - some from API)
            overrideRatingsWithLocalData(searchResults); // DB 평점/잔혹도 덮어쓰기 (Read - some from DB for override)
            model.addAttribute("apiMovies", searchResults); // 검색 결과 추가
            model.addAttribute("searchPerformed", true); // 검색 수행 플래그
            model.addAttribute("query", query); // 검색 쿼리 유지
        } else {
            model.addAttribute("searchPerformed", false); // 검색 미수행 플래그
        }
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "movie/apiSearchPage"; // "movie/apiSearchPage.jsp" 뷰 반환
    }

    // searchMoviesFromHeader 메서드: "/search" 경로에 대한 GET 요청 처리
    // 목적: 헤더 검색창에서 영화를 검색할 때 사용되며, API 검색 페이지로 연결. (Read(some) from API)
    @GetMapping("/search")
    public String searchMoviesFromHeader(@RequestParam(value = "query", required = false) String query, Model model, HttpSession session) {
        logger.info("[GET /search] 헤더 검색 요청. 쿼리: {}", query);
        if (query != null && !query.trim().isEmpty()) {
            List<movie> searchResults = externalMovieApiService.searchMoviesByKeyword(query); // 외부 API 검색 (Read - some from API)
            overrideRatingsWithLocalData(searchResults); // DB 평점/잔혹도 덮어쓰기 (Read - some from DB for override)
            model.addAttribute("apiMovies", searchResults); // 검색 결과 추가
            model.addAttribute("searchPerformed", true); // 검색 수행 플래그
            model.addAttribute("query", query); // 검색 쿼리 유지
        } else {
            model.addAttribute("searchPerformed", false); // 검색 미수행 플래그
        }
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "movie/apiSearchPage"; // "movie/apiSearchPage.jsp" 뷰 반환
    }

    // getApiExternalMovieDetail 메서드: "/movies/api-external-detail" 경로에 대한 GET 요청 처리
    // 목적: 외부 API에서 가져온 영화의 상세 정보를 보여줌. 우리 DB에 있다면 평점/잔혹도 덮어씀. (Read(one) from API and possibly one from DB)
    @GetMapping("/movies/api-external-detail")
    public String getApiExternalMovieDetail(@RequestParam("imdbId") String imdbId, Model model, HttpSession session, RedirectAttributes redirectAttributes) {
        try {
            movie externalMovieDetail = externalMovieApiService.getMovieFromApi(imdbId); // 외부 API에서 상세 정보 가져옴 (Read - one from API)

            if (externalMovieDetail != null) {
                // 상세 페이지 (API 상세)에서도 DB 평점/잔혹도 덮어쓰기 로직
                movie localMovie = movieService.findByApiId(externalMovieDetail.getApiId()); // DB에서 API ID로 영화 조회 (Read - one from DB)
                if (localMovie != null) {
                    externalMovieDetail.setRating(localMovie.getRating());
                    externalMovieDetail.setviolence_score_avg(localMovie.getviolence_score_avg());
                    logger.debug("API 상세 페이지에 영화 '{}' (apiId: {})의 평점/잔혹도를 로컬 DB 데이터로 덮어씀.", externalMovieDetail.getTitle(), externalMovieDetail.getApiId());
                } else {
                    logger.debug("API 상세 페이지에 영화 '{}' (apiId: {})는 로컬 DB에 없어 API 평점/잔혹도 유지.", externalMovieDetail.getTitle(), externalMovieDetail.getApiId());
                }

                model.addAttribute("movie", externalMovieDetail); // 'movie' 객체 모델에 추가
                model.addAttribute("userRole", session.getAttribute("userRole"));
                return "movie/detailPage"; // "movie/detailPage.jsp" 뷰 반환
            } else {
                logger.warn("[GET /movies/api-external-detail] imdbID '{}'에 해당하는 영화 정보를 API에서 찾을 수 없습니다.", imdbId);
                redirectAttributes.addAttribute("error", "movieNotFound"); // 오류 코드 전달
                return "redirect:/movies/search-api"; // 검색 페이지로 리다이렉트
            }
        } catch (Exception e) {
            logger.error("API 외부 영화 상세 정보 가져오기 실패: {}", e.getMessage(), e);
            redirectAttributes.addAttribute("error", "apiError"); // 오류 코드 전달
            return "redirect:/movies/search-api"; // 검색 페이지로 리다이렉트
        }
    }

    // overrideRatingsWithLocalData 헬퍼 메서드: API 영화 목록의 평점/잔혹도를 로컬 DB 데이터로 덮어씀.
    // 목적: 외부 API 데이터와 우리 시스템의 내부 데이터를 일관되게 보여줌.
    private void overrideRatingsWithLocalData(List<movie> apiMovies) {
        for (movie apiMovie : apiMovies) {
            movie localMovie = movieService.findByApiId(apiMovie.getApiId()); // DB에서 영화 조회 (Read(one) from DB)
            if (localMovie != null) {
                apiMovie.setRating(localMovie.getRating());
                apiMovie.setviolence_score_avg(localMovie.getviolence_score_avg());
                logger.debug("영화 '{}' (apiId: {})의 평점/잔혹도를 로컬 DB 데이터로 덮어씀.", apiMovie.getTitle(), apiMovie.getApiId());
            } else {
                logger.debug("영화 '{}' (apiId: {})는 로컬 DB에 없어 API 평점/잔혹도 유지.", apiMovie.getTitle(), apiMovie.getApiId());
            }
        }
    }

    // accessDenied 메서드: "/accessDenied" 경로에 대한 GET 요청 처리
    // 목적: 접근 권한이 없는 사용자에게 보여주는 페이지.
    @GetMapping("/accessDenied")
    public String accessDenied() {
        return "accessDenied"; // "accessDenied.jsp" 뷰 반환
    }

    // --- Update ---
    // editForm 메서드: "/movies/{id}/edit" 경로에 대한 GET 요청 처리
    // 목적: 특정 영화의 기존 정보를 가져와 수정할 폼 제공 (관리자 전용). 
    @GetMapping("/movies/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, HttpSession session) {
        if (!isAdmin(session)) { // 관리자 권한 확인
            logger.warn("[GET /movies/{}/edit] 권한 없음: 비관리자 접근 시도.", id);
            return "redirect:/accessDenied";
        }
        logger.info("[GET /movies/{}/edit] 영화 수정 폼 요청: ID = {}", id, id);
        movie movie = movieService.findById(id); // 수정할 영화 정보 조회 

        if (movie == null) {
            logger.warn("[GET /movies/{}/edit] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
            return "redirect:/movies?error=notFound";
        }

        model.addAttribute("movie", movie); // 조회된 movie 객체 추가 (폼 데이터 채움)
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "movie/form"; // "movie/form.jsp" 뷰 반환
    }

    // update 메서드: "/movies/{id}/edit" 경로에 대한 POST 요청 처리
    // 목적: 폼에 입력된 수정된 영화 정보를 DB에 업데이트하고, 새 포스터 이미지 처리 (관리자 전용).
    @PostMapping("/movies/{id}/edit")
    public String update(@PathVariable Long id,
                         @ModelAttribute movie movie,
                         @RequestParam("posterImage") MultipartFile posterImage,
                         HttpServletRequest request, HttpSession session) {
        if (!isAdmin(session)) { // 관리자 권한 확인
            logger.warn("[POST /movies/{}/edit] 권한 없음: 비관리자 영화 업데이트 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/{}/edit] 영화 업데이트 요청: ID = {}, 제목 = {}", id, movie.getTitle());
        movie.setId(id); // movie 객체 ID 설정

        movie existingMovie = movieService.findById(id); // 기존 영화 정보 가져옴
        String oldPosterPath = existingMovie != null ? existingMovie.getPosterPath() : null;

        // 새 포스터 이미지 업로드 및 기존 이미지 삭제 처리
        if (posterImage != null && !posterImage.isEmpty()) {
            try {
                String realUploadPath = request.getSession().getServletContext().getRealPath(UPLOAD_DIRECTORY_RELATIVE);
                File uploadDir = new File(realUploadPath);
                if (!uploadDir.exists()) { uploadDir.mkdirs(); }

                if (oldPosterPath != null && !oldPosterPath.startsWith("http://") && !oldPosterPath.startsWith("https://")) {
                    Path oldFilePath = Paths.get(request.getSession().getServletContext().getRealPath(oldPosterPath));
                    if (Files.exists(oldFilePath)) { Files.delete(oldFilePath); logger.info("기존 포스터 이미지 삭제 성공: {}", oldPosterPath); }
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
                movie.setPosterPath(UPLOAD_DIRECTORY_RELATIVE + savedFileName); // 상대 경로 설정
            } catch (IOException e) {
                logger.error("포스터 이미지 업데이트 실패: {}", e.getMessage(), e);
                movie.setPosterPath(oldPosterPath); // 실패 시 기존 경로 유지
            }
        } else {
            logger.info("[POST /movies/{}/edit] 새로운 포스터 이미지 업로드 없음. 기존 경로 유지.", id);
            movie.setPosterPath(oldPosterPath); // 새 파일 없으면 기존 경로 유지
        }

        movieService.update(movie); // 영화 정보 업데이트 (Update)
        logger.info("영화 '{}' 업데이트 완료.", movie.getTitle());
        return "redirect:/movies"; // 영화 목록으로 리다이렉트
    }

    // --- Delete ---
    // delete 메서드: "/movies/{id}/delete" 경로에 대한 POST 요청 처리
    // 목적: 특정 영화 정보와 관련된 로컬 포스터 이미지 파일을 DB에서 삭제 (관리자 전용).
    @PostMapping("/movies/{id}/delete")
    public String delete(@PathVariable Long id, HttpServletRequest request, HttpSession session) {
        if (!isAdmin(session)) { // 관리자 권한 확인
            logger.warn("[POST /movies/{}/delete] 권한 없음: 비관리자 영화 삭제 시도.", id);
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/{}/delete] 영화 삭제 요청: ID = {}", id, id);

        movie movieToDelete = movieService.findById(id); // 삭제할 영화 정보 조회 (Read - one from DB)
        if (movieToDelete != null && movieToDelete.getPosterPath() != null) {
            if (!movieToDelete.getPosterPath().startsWith("http://") && !movieToDelete.getPosterPath().startsWith("https://")) { // 로컬 파일인지 확인
                try {
                    String realPath = request.getSession().getServletContext().getRealPath(movieToDelete.getPosterPath());
                    Path filePath = Paths.get(realPath);
                    if (Files.exists(filePath)) { Files.delete(filePath); logger.info("삭제할 영화의 포스터 이미지 파일 삭제 완료: {}", realPath); }
                } catch (IOException e) {
                    logger.error("영화 삭제 시 포스터 이미지 파일 삭제 실패: {}", e.getMessage(), e);
                }
            } else {
                logger.debug("API 이미지이거나 포스터 경로가 없어 파일 삭제 스킵: {}", movieToDelete.getPosterPath());
            }
        } else {
            logger.debug("삭제할 영화가 없거나 포스터 경로가 없어 파일 삭제 스킵.");
        }

        movieService.delete(id); // DB에서 영화 정보 삭제 (Delete)
        logger.info("영화 ID {} 삭제 완료.", id);
        return "redirect:/movies"; // 영화 목록으로 리다이렉트
    }
}