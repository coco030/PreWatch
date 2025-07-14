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
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Controller
@RequestMapping("/movies") // 클래스 레벨 매핑: 모든 메서드 경로 앞에 "/movies"가 붙음
public class movieController {

    private static final Logger logger = LoggerFactory.getLogger(movieController.class);

    // 업로드된 이미지가 저장될 실제 경로 (webapp/resources/images/movies/)
    private static final String UPLOAD_DIRECTORY_RELATIVE = "/resources/images/movies/";

    private final movieService movieService;
    private final externalMovieApiService externalMovieApiService;

    @Autowired
    public movieController(movieService movieService, externalMovieApiService externalMovieApiService) {
        this.movieService = movieService;
        this.externalMovieApiService = externalMovieApiService;
    }

    // ------------------------- 1. 영화 목록 (Read All) -------------------------
    // GET /movies 또는 GET /movies/ (클래스 레벨 @RequestMapping과 조합)
    @GetMapping({"", "/"}) // /movies 와 /movies/ 둘 다 처리
    public String list(Model model) {
        logger.info("[GET /movies] 영화 목록 요청이 들어왔습니다.");
        model.addAttribute("movies", movieService.findAll());
        logger.debug("[GET /movies] movieService.findAll() 호출 완료.");
        return "movie/list"; // /WEB-INF/views/movie/list.jsp 뷰 반환
    }

    // ------------------------- 2. 새 영화 등록 폼 (Create Form) -------------------------
    // GET /movies/new
    @GetMapping("/new")
    public String createForm(Model model) {
        logger.info("[GET /movies/new] 새 영화 등록 폼 요청.");
        model.addAttribute("movie", new movie()); // 빈 movie 객체 전달
        return "movie/form"; // /WEB-INF/views/movie/form.jsp 뷰 반환
    }

    // ------------------------- 3. 영화 등록 처리 (Create Process) -------------------------
    // POST /movies (새 영화 등록 폼 제출 시)
    @PostMapping // @RequestMapping("/movies")와 조합되어 POST /movies 처리
    public String create(@ModelAttribute movie movie,
                         @RequestParam("posterImage") MultipartFile posterImage, // 파일 업로드 파라미터
                         HttpServletRequest request) { // 서버의 실제 파일 경로를 얻기 위해
        logger.info("[POST /movies] 새 영화 등록 요청: 제목 = {}", movie.getTitle());

        if (posterImage != null && !posterImage.isEmpty()) { // 파일이 업로드된 경우
            try {
                // 웹 애플리케이션의 실제(물리적) 경로 얻기
                String realUploadPath = request.getSession().getServletContext().getRealPath(UPLOAD_DIRECTORY_RELATIVE);
                File uploadDir = new File(realUploadPath);
                if (!uploadDir.exists()) { // 디렉토리가 없으면 생성
                    uploadDir.mkdirs();
                    logger.debug("업로드 디렉토리 생성: {}", realUploadPath);
                }

                // 파일명 중복 방지를 위한 UUID 사용
                String originalFileName = posterImage.getOriginalFilename();
                String fileExtension = "";
                if (originalFileName != null && originalFileName.contains(".")) {
                    fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                }
                String savedFileName = UUID.randomUUID().toString() + fileExtension; // 고유한 파일명
                Path filePath = Paths.get(realUploadPath, savedFileName);

                Files.copy(posterImage.getInputStream(), filePath); // 파일 저장
                logger.info("포스터 이미지 저장 성공: {}", filePath.toString());

                // DB에 저장할 웹 접근 경로 설정 (예: /resources/images/movies/uuid.jpg)
                movie.setPosterPath(UPLOAD_DIRECTORY_RELATIVE + savedFileName);

            } catch (IOException e) {
                logger.error("포스터 이미지 업로드 실패: {}", e.getMessage(), e);
                // 파일 업로드 실패 시, posterPath는 null 또는 기존값 유지 (여기서는 null)
                movie.setPosterPath(null);
            }
        } else {
            logger.info("[POST /movies] 업로드된 포스터 이미지 없음.");
            movie.setPosterPath(null);
        }

        movieService.save(movie); // DB에 영화 정보 저장 (포스터 경로 포함)
        logger.info("영화 '{}' DB에 저장 완료.", movie.getTitle());
        return "redirect:/movies"; // 저장 후 목록 페이지로 리다이렉트
    }

 // ------------------------- 4. 영화 상세 (Read One) -------------------------
 // GET /movies/{id}
 @GetMapping("/{id}")
 public String detail(@PathVariable Long id, Model model, HttpSession session) { // HttpSession 파라미터는 계속 유지됩니다.
     logger.info("[GET /movies/{}] 영화 상세 정보 요청: ID = {}", id, id);
     movie movie = movieService.findById(id); // DB에서 영화 정보 조회

     if (movie == null) {
         logger.warn("[GET /movies/{}] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
         return "redirect:/movies?error=notFound"; // 영화를 찾지 못하면 목록으로 리다이렉트
     }

     model.addAttribute("movie", movie);
     logger.debug("[GET /movies/{}] movieService.findById({}) 호출 완료.", id, id);
     
     return "movie/detailPage"; 
 }

    // ------------------------- 5. 영화 수정 폼 (Update Form) -------------------------
    // GET /movies/{id}/edit
    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        logger.info("[GET /movies/{}/edit] 영화 수정 폼 요청: ID = {}", id, id);
        movie movie = movieService.findById(id); // 수정할 기존 영화 정보 조회

        if (movie == null) {
            logger.warn("[GET /movies/{}/edit] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
            return "redirect:/movies?error=notFound";
        }

        model.addAttribute("movie", movie);
        return "movie/form"; // 등록/수정 폼 공유
    }

    // ------------------------- 6. 영화 수정 처리 (Update Process) -------------------------
    // POST /movies/{id}/edit
    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id,
                         @ModelAttribute movie movie,
                         @RequestParam("posterImage") MultipartFile posterImage, // 파일 업로드 파라미터
                         HttpServletRequest request) {
        logger.info("[POST /movies/{}/edit] 영화 업데이트 요청: ID = {}, 제목 = {}", id, movie.getTitle());
        movie.setId(id); // URL의 ID를 movie 객체에 설정

        // 기존 영화 정보 로드 (기존 포스터 경로를 알아야 함)
        movie existingMovie = movieService.findById(id);
        String oldPosterPath = existingMovie != null ? existingMovie.getPosterPath() : null;

        if (posterImage != null && !posterImage.isEmpty()) { // 새로운 이미지가 업로드된 경우
            try {
                String realUploadPath = request.getSession().getServletContext().getRealPath(UPLOAD_DIRECTORY_RELATIVE);
                File uploadDir = new File(realUploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // 기존 파일 삭제 (선택 사항: 불필요한 파일 누적 방지)
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

                Files.copy(posterImage.getInputStream(), filePath); // 새 파일 저장
                logger.info("새로운 포스터 이미지 저장 성공: {}", filePath.toString());
                movie.setPosterPath(UPLOAD_DIRECTORY_RELATIVE + savedFileName); // 새 경로 설정

            } catch (IOException e) {
                logger.error("포스터 이미지 업데이트 실패: {}", e.getMessage(), e);
                movie.setPosterPath(oldPosterPath); // 업로드 실패 시 기존 경로 유지
            }
        } else { // 새로운 이미지가 업로드되지 않은 경우
            logger.info("[POST /movies/{}/edit] 새로운 포스터 이미지 업로드 없음. 기존 경로 유지.", id);
            movie.setPosterPath(oldPosterPath); // 기존 경로 유지
        }

        movieService.update(movie); // DB 업데이트
        logger.info("영화 '{}' 업데이트 완료.", movie.getTitle());
        return "redirect:/movies"; // 업데이트 후 목록 페이지로 리다이렉트
    }

    // ------------------------- 7. 영화 삭제 (Delete) -------------------------
    // POST /movies/{id}/delete
    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, HttpServletRequest request) {
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

        movieService.delete(id); // DB에서 영화 삭제
        logger.info("영화 ID {} 삭제 완료.", id);
        return "redirect:/movies"; // 삭제 후 목록 페이지로 리다이렉트
    }

    // ------------------------- 8. API에서 영화 가져오기 (Import from API) -------------------------
    // POST /movies/import
    @PostMapping("/import")
    public String importFromApi(@RequestParam String title) {
        logger.info("[POST /movies/import] 영화 API 가져오기 요청: 제목 = {}", title);
        movie movieFromApi = externalMovieApiService.getMovieFromApi(title);

        if (movieFromApi != null) {
            logger.info("API에서 영화 '{}'를 성공적으로 가져왔습니다.", movieFromApi.getTitle());
            movieService.save(movieFromApi);
            logger.info("영화 '{}'를 DB에 저장 완료.", movieFromApi.getTitle());
            return "redirect:/movies";
        } else {
            logger.warn("[POST /movies/import] API에서 영화 '{}'를 찾지 못했거나 가져오기에 실패했습니다.", title);
            return "redirect:/movies?error=movieNotFound";
        }
    }
}