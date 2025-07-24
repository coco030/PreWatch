package com.springmvc.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.transaction.annotation.Transactional;

import com.springmvc.domain.Member;
import com.springmvc.domain.movie;
import com.springmvc.service.userCartService;
import com.springmvc.service.externalMovieApiService;
import com.springmvc.service.movieService;
import com.springmvc.service.AdminBannerMovieService; // ⭐ 새로 추가된 서비스 임포트 (7-24 오후12:41 추가 된 코드)

@Controller
public class movieController {
	
    private static final Logger logger = LoggerFactory.getLogger(movieController.class);

    private static final String UPLOAD_DIRECTORY_RELATIVE = "/resources/images/movies/";

    private final movieService movieService;
    private final externalMovieApiService externalMovieApiService;
    private final userCartService userCartService;
    private final AdminBannerMovieService adminBannerMovieService; // ⭐ 새로 추가된 서비스 필드 (7-24 오후12:41 추가 된 코드)


    @Autowired
    public movieController(movieService movieService, externalMovieApiService externalMovieApiService, userCartService userCartService,
                           AdminBannerMovieService adminBannerMovieService) { // ⭐ 생성자에도 추가 (7-24 오후12:41 추가 된 코드)
        this.movieService = movieService;
        this.externalMovieApiService = externalMovieApiService;
        this.userCartService = userCartService;
        this.adminBannerMovieService = adminBannerMovieService; // ⭐ 초기화 (7-24 오후12:41 추가 된 코드)
    }

    private boolean isAdmin(HttpSession session) {
        String userRole = (String) session.getAttribute("userRole");
        return "ADMIN".equals(userRole);
    }

    private boolean isMember(HttpSession session) {
        String userRole = (String) session.getAttribute("userRole");
        return "MEMBER".equals(userRole);
    }

    // --- Create (생성) 작업 ---
    // 새 영화 등록 폼 페이지 요청
    @GetMapping("/movies/new")
    public String createForm(Model model, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[GET /movies/new] 권한 없음: 비관리자 접근 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[GET /movies/new] 새 영화 등록 폼 요청.");
        model.addAttribute("movie", new movie());
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "movie/form";
    }

    // 새 영화 등록 처리
    @PostMapping("/movies")
    public String create(@ModelAttribute movie movie,
                         @RequestParam("posterImage") MultipartFile posterImage,
                         HttpServletRequest request, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[POST /movies] 권한 없음: 비관리자 영화 등록 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies] 새 영화 등록 요청: 제목 = {}", movie.getTitle());

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
                movie.setPosterPath(UPLOAD_DIRECTORY_RELATIVE + savedFileName);
            } catch (IOException e) {
                logger.error("포스터 이미지 업로드 실패: {}", e.getMessage(), e);
                movie.setPosterPath(null);
            }
        } else {
            logger.info("[POST /movies] 업로드된 포스터 이미지 없음.");
            movie.setPosterPath(null);
        }

        // isRecommended 로직 제거: 수동 등록 영화는 이제 별도의 배너 관리 프로세스를 따릅니다. (7-24 오후12:41 추가 된 코드)
        movieService.save(movie);
        logger.info("영화 '{}' DB에 저장 완료.", movie.getTitle());
        return "redirect:/movies";
    }

    // 외부 API에서 영화 상세 정보 가져와 등록 처리
    @PostMapping("/movies/import-api-detail")
    public String importApiMovieDetail(@RequestParam("imdbId") String imdbId, Model model, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[POST /movies/import-api-detail] 권한 없음: 비관리자 API 영화 등록 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/import-api-detail] API에서 영화 상세 정보 가져와 등록 요청: imdbID = {}", imdbId);

        movie movieFromApi = externalMovieApiService.getMovieFromApi(imdbId);

        if (movieFromApi != null) {
            // isRecommended 로직 제거 (7-24 오후12:41 추가 된 코드)
            movieService.save(movieFromApi);
            logger.info("API 영화 '{}' (ID: {}) DB에 성공적으로 등록.", movieFromApi.getTitle(), movieFromApi.getApiId());
            return "redirect:/movies?status=registered";
        } else {
            logger.warn("[POST /movies/import-api-detail] imdbID '{}'에 해당하는 영화 정보를 API에서 찾을 수 없습니다.", imdbId);
            model.addAttribute("errorMessage", "영화 상세 정보를 찾을 수 없습니다.");
            return "redirect:/search?error=detailNotFound";
        }
    }

    // --- Read (조회) 작업 ---
    // read-one: 특정 영화 상세 정보 조회
    @GetMapping("/movies/{id}")
    @Transactional(readOnly = true)
    public String detail(@PathVariable Long id, Model model, HttpSession session) {
        logger.info("[GET /movies/{}] 영화 상세 정보 요청: ID = {}", id, id);
        movie movie = movieService.findById(id); // DB에서 영화 정보 조회

        if (movie == null) {
            logger.warn("[GET /movies/{}] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
            return "redirect:/movies?error=notFound";
        }

        logger.debug("상세 페이지 로드 - 영화 ID: {}, 제목: '{}', DB에서 가져온 likeCount: {}", // isRecommended 로깅 제거 (7-24 오후12:41 추가 된 코드)
                                 movie.getId(), movie.getTitle(), movie.getLikeCount());


        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            boolean isLiked = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
            movie.setIsLiked(isLiked);
            logger.debug("상세 페이지 - 영화 '{}' (ID: {})의 찜 상태: {}", movie.getTitle(), movie.getId(), isLiked);
        } else {
            movie.setIsLiked(false);
        }

        model.addAttribute("movie", movie);
        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("[GET /movies/{}] movieService.findById({}) 호출 완료.", id, id);

        return "movie/detailPage";
    }

    // read-all: 모든 영화 목록 조회
    @GetMapping({"/movies", "/movies/"})
    @Transactional(readOnly = true)
    public String list(Model model, HttpSession session) {
        logger.info("[GET /movies] 영화 목록 요청이 들어왔습니다.");
        // findAll()이 이미 like_count 기준으로 정렬되어 있으므로 별도 변경 필요 없음
        List<movie> movies = movieService.findAll();

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            logger.debug("로그인된 일반 회원 ({})의 영화 목록 찜 상태 반영 시작.", loginMember.getId());
            for (movie movie : movies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 영화 ID: {}, 제목: '{}', userCartService.isMovieLiked() 반환값: {}, movie.isLiked() 최종 설정값: {}, likeCount: {}",
                                         movie.getId(), movie.getTitle(), isMovieLikedByCurrentUser, movie.isLiked(), movie.getLikeCount());
            }
            logger.debug("로그인된 일반 회원 ({})의 영화 목록 찜 상태 반영 완료.", loginMember.getId());
        } else {
            logger.debug("비로그인 또는 관리자 계정으로 영화 목록 요청. 찜 상태 미반영.");
        }

        model.addAttribute("movies", movies);
        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("[GET /movies] movieService.findAll() 호출 완료.");
        return "movie/list";
    }

    // read-some: 메인 페이지 데이터 (최근 등록, 추천 랭킹)
    // ⭐ 메인 페이지 (main.jsp) 요청 처리 메서드: 이제 HomeController가 '/'를 담당하므로 이 메서드는 /main 경로만 처리합니다. ⭐ (7-24 오후12:41 추가 된 코드)
    @GetMapping("/main") // (7-24 오후12:41 추가 된 코드)
    @Transactional(readOnly = true) // (7-24 오후12:41 추가 된 코드)
    public String mainPage(Model model, HttpSession session) { // (7-24 오후12:41 추가 된 코드)
        logger.info("[GET /main] 메인 페이지 (별도 경로) 요청이 들어왔습니다."); // (7-24 오후12:41 추가 된 코드)

        // 1. 최근 등록된 영화 목록 가져오기 (상위 3개) (7-24 오후12:41 추가 된 코드)
        List<movie> recentMovies = movieService.getRecentMovies(3); // (7-24 오후12:41 추가 된 코드)
        model.addAttribute("movies", recentMovies); // 'movies'는 main.jsp의 "최근 등록된 영화" 섹션에 바인딩 (7-24 오후12:41 추가 된 코드)

        // 2. PreWatch 추천 랭킹 영화 목록 가져오기 (like_count 기준 상위 5개) (7-24 오후12:41 추가 된 코드)
        List<movie> recommendedMovies = movieService.getTop5RecommendedMovies(); // (7-24 오후12:41 추가 된 코드)
        model.addAttribute("recommendedMovies", recommendedMovies); // 'recommendedMovies'는 main.jsp의 "추천 랭킹" 섹션에 바인딩 (7-24 오후12:41 추가 된 코드)


        Member loginMember = (Member) session.getAttribute("loginMember"); // (7-24 오후12:41 추가 된 코드)
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) { // (7-24 오후12:41 추가 된 코드)
            logger.debug("메인 페이지 (별도 경로) - 로그인된 일반 회원 ({})의 찜 상태 반영 시작.", loginMember.getId()); // (7-24 오후12:41 추가 된 코드)
            // recentMovies와 recommendedMovies 모두에 찜 상태 반영 (7-24 오후12:41 추가 된 코드)
            for (movie movie : recentMovies) { // (7-24 오후12:41 추가 된 코드)
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId()); // (7-24 오후12:41 추가 된 코드)
                movie.setIsLiked(isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
                logger.debug("  - 최근 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
            } // (7-24 오후12:41 추가 된 코드)
            for (movie movie : recommendedMovies) { // (7-24 오후12:41 추가 된 코드)
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId()); // (7-24 오후12:41 추가 된 코드)
                movie.setIsLiked(isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
                logger.debug("  - 추천 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
            } // (7-24 오후12:41 추가 된 코드)
            // adminRecommendedMovies 찜 상태 반영 로직 제거 (7-24 오후12:41 추가 된 코드)
            logger.debug("메인 페이지 (별도 경로) - 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId()); // (7-24 오후12:41 추가 된 코드)
        } else { // (7-24 오후12:41 추가 된 코드)
            logger.debug("메인 페이지 (별도 경로) - 비로그인 또는 관리자 계정으로 찜 상태 미반영."); // (7-24 오후12:41 추가 된 코드)
        } // (7-24 오후12:41 추가 된 코드)

        model.addAttribute("userRole", session.getAttribute("userRole")); // (7-24 오후12:41 추가 된 코드)
        logger.debug("[GET /main] 메인 페이지 (별도 경로) 데이터 로딩 완료."); // (7-24 오후12:41 추가 된 코드)
        return "layout/main"; // main.jsp 경로 (7-24 오후12:41 추가 된 코드)
    } // (7-24 오후12:41 추가 된 코드)

    // read-some: API 영화 검색 페이지 또는 검색 결과
    @GetMapping("/movies/search-api")
    @Transactional(readOnly = true)
    public String searchApiMoviesPage(@RequestParam(value = "query", required = false) String query, Model model, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[GET /movies/search-api] 권한 없음: 비관리자 API 검색 페이지 접근 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[GET /movies/search-api] API 영화 검색 페이지 또는 검색 결과 요청. 쿼리: {}", query);
        if (query != null && !query.trim().isEmpty()) {
            List<movie> searchResults = externalMovieApiService.searchMoviesByKeyword(query);
            overrideRatingsWithLocalData(searchResults);

            Member loginMember = (Member) session.getAttribute("loginMember");
            if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
                for (movie movie : searchResults) {
                    if (movie.getId() != null) {
                        boolean isLiked = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                        movie.setIsLiked(isLiked);
                    } else {
                        movie.setIsLiked(false);
                    }
                }
                logger.debug("API 검색 결과에 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId());
            } else {
                logger.debug("API 검색 결과에 비로그인 또는 관리자 계정으로 찜 상태 미반영.");
            }

            model.addAttribute("apiMovies", searchResults);
            model.addAttribute("searchPerformed", true);
            model.addAttribute("query", query);
        } else {
            model.addAttribute("searchPerformed", false);
        }
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "movie/apiSearchPage";
    }

    // read-some: 헤더 검색 결과
    @GetMapping("/search")
    @Transactional(readOnly = true)
    public String searchMoviesFromHeader(@RequestParam(value = "query", required = false) String query, Model model, HttpSession session) {
        logger.info("[GET /search] 헤더 검색 요청. 쿼리: {}", query);
        if (query != null && !query.trim().isEmpty()) {
            List<movie> searchResults = externalMovieApiService.searchMoviesByKeyword(query);
            overrideRatingsWithLocalData(searchResults);

            Member loginMember = (Member) session.getAttribute("loginMember");
            if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
                for (movie movie : searchResults) {
                    if (movie.getId() != null) {
                        boolean isLiked = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                        movie.setIsLiked(isLiked);
                    } else {
                        movie.setIsLiked(false);
                    }
                }
                logger.debug("헤더 검색 결과에 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId());
            } else {
                logger.debug("헤더 검색 결과에 비로그인 또는 관리자 계정으로 찜 상태 미반영.");
            }

            model.addAttribute("apiMovies", searchResults);
            model.addAttribute("searchPerformed", true);
            model.addAttribute("query", query);
        } else {
            model.addAttribute("searchPerformed", false);
        }
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "movie/apiSearchPage";
    }

    // read-one: 외부 API 영화 상세 정보 조회
    @GetMapping("/movies/api-external-detail")
    @Transactional(readOnly = true)
    public String getApiExternalMovieDetail(@RequestParam("imdbId") String imdbId, Model model, HttpSession session, RedirectAttributes redirectAttributes) {
        try {
            movie externalMovieDetail = externalMovieApiService.getMovieFromApi(imdbId);

            if (externalMovieDetail != null) {
                movie localMovie = movieService.findByApiId(externalMovieDetail.getApiId());
                if (localMovie != null) {
                    externalMovieDetail.setRating(localMovie.getRating());
                    externalMovieDetail.setViolence_score_avg(localMovie.getViolence_score_avg());
                    externalMovieDetail.setId(localMovie.getId());
                    externalMovieDetail.setLikeCount(localMovie.getLikeCount());
                    // isRecommended 로직 제거 (7-24 오후12:41 추가 된 코드)

                    Member loginMember = (Member) session.getAttribute("loginMember");
                    if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
                        boolean isLiked = userCartService.isMovieLiked(loginMember.getId(), localMovie.getId());
                        externalMovieDetail.setIsLiked(isLiked);
                        logger.debug("API 상세 페이지 (DB 존재) 영화 '{}'의 찜 상태: {}", externalMovieDetail.getTitle(), isLiked);
                    } else {
                        externalMovieDetail.setIsLiked(false);
                    }

                } else {
                    logger.debug("API 상세 페이지에 영화 '{}' (apiId: {})는 로컬 DB에 없어 API 평점/잔혹도/찜개수 유지.", externalMovieDetail.getTitle(), externalMovieDetail.getApiId());
                    externalMovieDetail.setIsLiked(false);
                    externalMovieDetail.setLikeCount(0);
                    // isRecommended 로직 제거 (7-24 오후12:41 추가 된 코드)
                }

                model.addAttribute("movie", externalMovieDetail);
                model.addAttribute("userRole", session.getAttribute("userRole"));
                return "movie/detailPage";
            } else {
                logger.warn("[GET /movies/api-external-detail] imdbID '{}'에 해당하는 영화 정보를 API에서 찾을 수 없습니다.", imdbId);
                redirectAttributes.addAttribute("error", "movieNotFound");
                return "redirect:/movies/search-api";
            }
        } catch (Exception e) {
            logger.error("API 외부 영화 상세 정보 가져오기 실패: {}", e.getMessage(), e);
            redirectAttributes.addAttribute("error", "apiError");
            return "redirect:/movies/search-api";
        }
    }

    // API 검색 결과에 로컬 데이터 덮어쓰기 (내부 도우미 메서드)
    private void overrideRatingsWithLocalData(List<movie> apiMovies) {
        for (movie apiMovie : apiMovies) {
            movie localMovie = movieService.findByApiId(apiMovie.getApiId());
            if (localMovie != null) {
                apiMovie.setRating(localMovie.getRating());
                apiMovie.setViolence_score_avg(localMovie.getViolence_score_avg());
                apiMovie.setId(localMovie.getId());
                apiMovie.setLikeCount(localMovie.getLikeCount());
                // isRecommended 로직 제거 (7-24 오후12:41 추가 된 코드)
                logger.debug("영화 '{}' (apiId: {})의 평점/잔혹도/찜개수를 로컬 DB 데이터로 덮어씀.", apiMovie.getTitle(), apiMovie.getApiId());
            } else {
                logger.debug("영화 '{}' (apiId: {})는 로컬 DB에 없어 API 평점/잔혹도/찜개수 유지.", apiMovie.getTitle(), apiMovie.getApiId());
                apiMovie.setLikeCount(0);
                // isRecommended 로직 제거 (7-24 오후12:41 추가 된 코드)
            }
        }
    }

    // 접근 거부 페이지
    @GetMapping("/accessDenied")
    public String accessDenied() {
        return "accessDenied";
    }

    // --- Update (수정) 작업 ---
    // 영화 수정 폼 페이지 요청
    @GetMapping("/movies/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[GET /movies/{}/edit] 권한 없음: 비관리자 접근 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[GET /movies/{}/edit] 영화 수정 폼 요청: ID = {}", id, id);
        movie movie = movieService.findById(id);

        if (movie == null) {
            logger.warn("[GET /movies/{}/edit] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
            return "redirect:/movies?error=notFound";
        }

        model.addAttribute("movie", movie);
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "movie/form";
    }

    // 영화 정보 업데이트 처리
    @PostMapping("/movies/{id}/edit")
    public String update(@PathVariable Long id,
                         @ModelAttribute movie movie,
                         @RequestParam("posterImage") MultipartFile posterImage,
                         HttpServletRequest request, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[POST /movies/{}/edit] 권한 없음: 비관리자 영화 업데이트 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/{}/edit] 영화 업데이트 요청: ID = {}, 제목 = {}", id, movie.getTitle());
        movie.setId(id);

        movie existingMovie = movieService.findById(id);
        String oldPosterPath = existingMovie != null ? existingMovie.getPosterPath() : null;
        movie.setLikeCount(existingMovie != null ? existingMovie.getLikeCount() : 0);
        // isRecommended 로직 제거 (7-24 오후12:41 추가 된 코드)

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
        logger.info("영화 '{}' 업데이트 완료.", movie.getTitle()); // isRecommended 로깅 제거 (7-24 오후12:41 추가 된 코드)
        return "redirect:/movies";
    }

    // --- Delete (삭제) 작업 ---
    // 영화 삭제 처리
    @PostMapping("/movies/{id}/delete")
    public String delete(@PathVariable Long id, HttpServletRequest request, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[POST /movies/{}/delete] 권한 없음: 비관리자 영화 삭제 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /movies/{}/delete] 영화 삭제 요청: ID = {}", id, id);

        movie movieToDelete = movieService.findById(id);
        if (movieToDelete != null && movieToDelete.getPosterPath() != null) {
            if (!movieToDelete.getPosterPath().startsWith("http://") && !movieToDelete.getPosterPath().startsWith("https://")) {
                try {
                    String realPath = request.getSession().getServletContext().getRealPath(movieToDelete.getPosterPath());
                    Path filePath = Paths.get(realPath);
                    if (Files.exists(filePath)) { Files.delete(filePath); logger.info("기존 포스터 이미지 삭제 완료: {}", realPath); }
                } catch (IOException e) {
                    logger.error("영화 삭제 시 포스터 이미지 파일 삭제 실패: {}", e.getMessage(), e);
                }
            } else {
                logger.debug("API 이미지이거나 포스터 경로가 없어 파일 삭제 스킵: {}", movieToDelete.getPosterPath());
            }
        } else {
            logger.debug("삭제할 영화가 없거나 포스터 경로가 없어 파일 삭제 스킵.");
        }

        movieService.delete(id);
        logger.info("영화 ID {} 삭제 완료.", id);
        return "redirect:/movies";
    }

    // --- 기타 기능 ---
    // Cart (찜) 기능 토글
    @PostMapping("/movies/{movieId}/toggleCart")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleCart(@PathVariable Long movieId, HttpSession session) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null || !"MEMBER".equals(loginMember.getRole())) {
            logger.warn("[POST /movies/{}/toggleCart] 권한 없음: 비로그인 또는 비회원 계정의 찜 시도.", movieId);
            return new ResponseEntity<>(Map.of("message", "로그인한 일반 회원만 찜 기능을 사용할 수 있습니다.", "status", "forbidden"), HttpStatus.FORBIDDEN);
        }

        String memberId = loginMember.getId();
        logger.info("[POST /movies/{}/toggleCart] 회원 '{}'의 영화 ID '{}' 찜 토글 요청.", memberId, movieId);

        try {
            Map<String, Object> result = userCartService.addOrRemoveMovie(memberId, movieId);
            return new ResponseEntity<>(result, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("찜 토글 처리 중 오류 발생 (memberId={}, movieId={}): {}", memberId, movieId, e.getMessage(), e);
            return new ResponseEntity<>(Map.of("message", "찜 처리 중 오류가 발생했습니다.", "status", "error"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // ⭐ 관리자용 수동 추천 영화 관리 페이지 (Read-All for Admin) ⭐ (7-24 오후12:41 추가 된 코드)
    @GetMapping("/admin/banner-movies") // (7-24 오후12:41 추가 된 코드)
    public String adminBannerMovies(Model model, HttpSession session) { // (7-24 오후12:41 추가 된 코드)
        if (!isAdmin(session)) { // (7-24 오후12:41 추가 된 코드)
            logger.warn("[GET /admin/banner-movies] 권한 없음: 비관리자 접근 시도."); // (7-24 오후12:41 추가 된 코드)
            return "redirect:/accessDenied"; // (7-24 오후12:41 추가 된 코드)
        } // (7-24 오후12:41 추가 된 코드)
        logger.info("[GET /admin/banner-movies] 관리자 수동 추천 영화 관리 페이지 요청."); // (7-24 오후12:41 추가 된 코드)

        List<movie> allMovies = movieService.findAll(); // 모든 영화 목록 (추천할 영화 선택용) (7-24 오후12:41 추가 된 코드)
        List<movie> currentAdminBannerMovies = adminBannerMovieService.getAdminRecommendedMovies(); // 현재 배너에 등록된 영화 (7-24 오후12:41 추가 된 코드)

        model.addAttribute("allMovies", allMovies); // (7-24 오후12:41 추가 된 코드)
        model.addAttribute("currentAdminBannerMovies", currentAdminBannerMovies); // (7-24 오후12:41 추가 된 코드)
        model.addAttribute("userRole", session.getAttribute("userRole")); // (7-24 오후12:41 추가 된 코드)
        return "admin/bannerMovieManage"; // ⭐ 새로운 JSP 파일 (admin/bannerMovieManage.jsp) (7-24 오후12:41 추가 된 코드)
    } // (7-24 오후12:41 추가 된 코드)

    // ⭐ 관리자 수동 추천 영화 추가 처리 (Create for Admin) ⭐ (7-24 오후12:41 추가 된 코드)
    @PostMapping("/admin/banner-movies/add") // (7-24 오후12:41 추가 된 코드)
    public String addBannerMovie(@RequestParam("movieId") Long movieId, RedirectAttributes redirectAttributes, HttpSession session) { // (7-24 오후12:41 추가 된 코드)
        if (!isAdmin(session)) { // (7-24 오후12:41 추가 된 코드)
            logger.warn("[POST /admin/banner-movies/add] 권한 없음: 비관리자 추천 영화 추가 시도."); // (7-24 오후12:41 추가 된 코드)
            return "redirect:/accessDenied"; // (7-24 오후12:41 추가 된 코드)
        } // (7-24 오후12:41 추가 된 코드)
        logger.info("[POST /admin/banner-movies/add] 수동 추천 영화 추가 요청: Movie ID = {}", movieId); // (7-24 오후12:41 추가 된 코드)

        try { // (7-24 오후12:41 추가 된 코드)
            // 이미 등록된 영화인지 확인 (7-24 오후12:41 추가 된 코드)
            if (adminBannerMovieService.isMovieInAdminBanner(movieId)) { // (7-24 오후12:41 추가 된 코드)
                redirectAttributes.addFlashAttribute("errorMessage", "이미 수동 추천 영화로 등록된 영화입니다."); // (7-24 오후12:41 추가 된 코드)
                return "redirect:/admin/banner-movies"; // (7-24 오후12:41 추가 된 코드)
            } // (7-24 오후12:41 추가 된 코드)

            adminBannerMovieService.addAdminRecommendedMovie(movieId); // (7-24 오후12:41 추가 된 코드)
            redirectAttributes.addFlashAttribute("successMessage", "영화가 수동 추천 배너에 추가되었습니다."); // (7-24 오후12:41 추가 된 코드)
        } catch (Exception e) { // (7-24 오후12:41 추가 된 코드)
            logger.error("수동 추천 영화 추가 실패 (movieId={}): {}", movieId, e.getMessage(), e); // (7-24 오후12:41 추가 된 코드)
            redirectAttributes.addFlashAttribute("errorMessage", "수동 추천 영화 추가 중 오류가 발생했습니다."); // (7-24 오후12:41 추가 된 코드)
        } // (7-24 오후12:41 추가 된 코드)
        return "redirect:/admin/banner-movies"; // (7-24 오후12:41 추가 된 코드)
    } // (7-24 오후12:41 추가 된 코드)

    // ⭐ 수동 추천 영화 삭제 처리 (Delete for Admin) ⭐ (7-24 오후12:41 추가 된 코드)
    @PostMapping("/admin/banner-movies/delete") // (7-24 오후12:41 추가 된 코드)
    public String deleteBannerMovie(@RequestParam("movieId") Long movieId, RedirectAttributes redirectAttributes, HttpSession session) { // (7-24 오후12:41 추가 된 코드)
        if (!isAdmin(session)) { // (7-24 오후12:41 추가 된 코드)
            logger.warn("[POST /admin/banner-movies/delete] 권한 없음: 비관리자 추천 영화 삭제 시도."); // (7-24 오후12:41 추가 된 코드)
            return "redirect:/accessDenied"; // (7-24 오후12:41 추가 된 코드)
        } // (7-24 오후12:41 추가 된 코드)
        logger.info("[POST /admin/banner-movies/delete] 수동 추천 영화 삭제 요청: Movie ID = {}", movieId); // (7-24 오후12:41 추가 된 코드)

        try { // (7-24 오후12:41 추가 된 코드)
            adminBannerMovieService.removeAdminRecommendedMovie(movieId); // (7-24 오후12:41 추가 된 코드)
            redirectAttributes.addFlashAttribute("successMessage", "영화가 수동 추천 배너에서 삭제되었습니다."); // (7-24 오후12:41 추가 된 코드)
        } catch (Exception e) { // (7-24 오후12:41 추가 된 코드)
            logger.error("수동 추천 영화 삭제 실패 (movieId={}): {}", movieId, e.getMessage(), e); // (7-24 오후12:41 추가 된 코드)
            redirectAttributes.addFlashAttribute("errorMessage", "수동 추천 영화 삭제 중 오류가 발생했습니다."); // (7-24 오후12:41 추가 된 코드)
        } // (7-24 오후12:41 추가 된 코드)
        return "redirect:/admin/banner-movies"; // (7-24 오후12:41 추가 된 코드)
    } // (7-24 오후12:41 추가 된 코드)
    
    
    // ============ coco030이 추가한 내역 ====
    // 최근 개봉 예정작

    @GetMapping("/movies/upcoming")
    public String showUpcomingMovies(Model model) {
        List<Map<String, Object>> upcomingMovies = movieService.getUpcomingMoviesWithDday();
        model.addAttribute("upcomingMovies", upcomingMovies);
        return "movie/upcomingMovies";
    }
	
// ===========coco030이 추가한 내역  끝 ==== ///
	
    
}