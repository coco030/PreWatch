package com.springmvc.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
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
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.springmvc.domain.Member;
import com.springmvc.domain.MovieImage;
import com.springmvc.domain.RecentCommentDTO;
import com.springmvc.domain.StatDTO;
import com.springmvc.domain.UserReview;
import com.springmvc.domain.movie;
import com.springmvc.repository.ActorRepository;
import com.springmvc.repository.StatRepository;
import com.springmvc.repository.movieRepository;
import com.springmvc.service.AdminBannerMovieService;
import com.springmvc.service.MovieImageService;
import com.springmvc.service.StatService;
import com.springmvc.service.StatServiceImpl.InsightMessage;
import com.springmvc.service.TmdbApiService;
import com.springmvc.service.UserReviewService;
import com.springmvc.service.externalMovieApiService;
import com.springmvc.service.movieService;
import com.springmvc.service.userCartService;

@Controller
public class movieController {
	
    private static final Logger logger = LoggerFactory.getLogger(movieController.class);

    private static final String UPLOAD_DIRECTORY_RELATIVE = "/resources/images/movies/";

    private final movieService movieService;
    private final externalMovieApiService externalMovieApiService;
    private final userCartService userCartService;
    private final AdminBannerMovieService adminBannerMovieService;
    private final TmdbApiService tmdbApiService;
    private final movieRepository movieRepository;
    private final ActorRepository actorRepository;
    private final UserReviewService userReviewService;
    private final MovieImageService movieImageService;
    private final StatService statService;

    @Autowired
    private StatRepository statRepository;
    
    @Autowired
    public movieController(movieService movieService,
                           externalMovieApiService externalMovieApiService,
                           userCartService userCartService,
                           AdminBannerMovieService adminBannerMovieService,
                           TmdbApiService tmdbApiService,
                           movieRepository movieRepository,
                           ActorRepository actorRepository,
                           UserReviewService userReviewService,
                           MovieImageService movieImageService, 
                           StatService statService) {
        this.movieService = movieService;
        this.externalMovieApiService = externalMovieApiService;
        this.userCartService = userCartService;
        this.adminBannerMovieService = adminBannerMovieService;
        this.tmdbApiService = tmdbApiService;
        this.movieRepository = movieRepository;
        this.actorRepository = actorRepository;
        this.userReviewService = userReviewService;
        this.movieImageService = movieImageService;
        this.statService = statService;
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

    @PostMapping("/movies")
    public String create(
            @ModelAttribute movie movie,
            @RequestParam("posterImage") MultipartFile posterImage,
            HttpServletRequest request,
            HttpSession session,
            Model model) {

        if (!isAdmin(session)) {
            logger.warn("[POST /movies] 권한 없음: 비관리자 영화 등록 시도.");
            return "redirect:/accessDenied";
        }

        logger.info("[POST /movies] 영화 등록 요청: 제목 = {}, IMDb ID = {}", movie.getTitle(), movie.getApiId());
        
     // 중복 등록 방지 25.08.04 coco030
        if (movie.getApiId() != null && movieService.existsByApiId(movie.getApiId())) {
            model.addAttribute("movie", movie);
            model.addAttribute("userRole", session.getAttribute("userRole"));
            model.addAttribute("errorMessage", "이미 등록된 영화입니다.");
            return "movie/form";
        }

        // 1. api_id가 입력된 경우: TMDB/OMDb에서 정보 자동 불러오기
        Integer tmdbId = null;
        if (movie.getApiId() != null && !movie.getApiId().isBlank()) {
            try {
                // TMDB ID를 찾는다 (없으면 null)
                tmdbId = tmdbApiService.getTmdbMovieId(movie.getApiId());

                // TMDB ID 유무와 상관없이, 영화 기본정보(타이틀, 장르 등)는 OMDb/IMDb 기반으로 매핑 (출연진 제외)
                Map<String, Object> movieInfo = tmdbApiService.getMovieDetailByImdbId(movie.getApiId());
                if (isBlank(movie.getTitle())) movie.setTitle((String) movieInfo.get("title"));
                if (isBlank(movie.getDirector())) movie.setDirector((String) movieInfo.get("director"));
                if (movie.getYear() == 0) movie.setYear((Integer) movieInfo.get("year"));
                if (movie.getReleaseDate() == null) movie.setReleaseDate((LocalDate) movieInfo.get("release_date"));
                if (isBlank(movie.getGenre())) movie.setGenre((String) movieInfo.get("genre"));
                if (isBlank(movie.getRated()) && movieInfo.get("rated") != null) {
                    movie.setRated((String) movieInfo.get("rated"));
                }
                if (isBlank(movie.getOverview())) movie.setOverview((String) movieInfo.get("overview"));
                if (isBlank(movie.getRuntime())) movie.setRuntime((String) movieInfo.get("runtime"));
                if (isBlank(movie.getPosterPath())) movie.setPosterPath((String) movieInfo.get("poster_path"));
                logger.info("영화 정보 자동 매핑 완료: {}", movie.getTitle());

            } catch (Exception e) {
                logger.warn("영화 정보 자동 채우기 실패: {}", e.getMessage());
            }
        }

        // 2. 포스터 수동 업로드 (자동 포스터 없을 때만 적용)
        if ((movie.getPosterPath() == null || movie.getPosterPath().isBlank()) && posterImage != null && !posterImage.isEmpty()) {
            try {
                String realUploadPath = request.getSession().getServletContext().getRealPath(UPLOAD_DIRECTORY_RELATIVE);
                File uploadDir = new File(realUploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                String originalFileName = posterImage.getOriginalFilename();
                String fileExtension = originalFileName != null && originalFileName.contains(".") ?
                        originalFileName.substring(originalFileName.lastIndexOf(".")) : "";
                String savedFileName = UUID.randomUUID().toString() + fileExtension;
                Path filePath = Paths.get(realUploadPath, savedFileName);

                Files.copy(posterImage.getInputStream(), filePath);
                movie.setPosterPath(UPLOAD_DIRECTORY_RELATIVE + savedFileName);
                logger.info("포스터 이미지 저장 성공: {}", filePath);
            } catch (IOException e) {
                logger.error("포스터 업로드 실패: {}", e.getMessage());
            }
        }

        // 3. 영화 DB 저장
        movieService.save(movie);
        logger.info("영화 '{}' 저장 완료. ID = {}", movie.getTitle(), movie.getId());

        // 4. 출연진 자동 저장 (TMDB ID가 있을 경우에만)
        if (tmdbId != null) {
            try {
                List<Map<String, String>> castAndCrew = tmdbApiService.getCastAndCrew(tmdbId);
                tmdbApiService.saveCastAndCrew(movie.getId(), castAndCrew);
                logger.info("출연진 자동 등록 완료: {}명", castAndCrew.size());
            } catch (Exception e) {
                logger.warn("출연진 자동 등록 실패: {}", e.getMessage());
            }
        } else {
            logger.info("TMDB ID가 없어 출연진 자동 등록을 건너뜀.");
        }

        return "redirect:/movies";
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    // coco030 추가 
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
            movieService.save(movieFromApi); // DB 저장(여기서 id가 할당됨)

            Long movieId = movieFromApi.getId(); // save 이후 id 할당됨

            // id가 null이면 selectIdSql로 강제 조회
            if (movieId == null) {
                movieId = movieService.findByApiId(movieFromApi.getApiId()).getId();
                movieFromApi.setId(movieId);
            }
            System.out.println("DEBUG: 저장된 영화 id = " + movieId);

            // TMDB 배우/감독 정보 저장
            Integer tmdbId = tmdbApiService.getTmdbMovieId(imdbId);
            if (tmdbId != null) {
                List<Map<String, String>> castAndCrew = tmdbApiService.getCastAndCrew(tmdbId);
                tmdbApiService.saveCastAndCrew(movieId, castAndCrew); // 반드시 null 아님!
            }

            logger.info("API 영화 '{}' (ID: {}) DB에 성공적으로 등록.", movieFromApi.getTitle(), movieFromApi.getApiId());
            return "redirect:/movies?status=registered";
        } else {
            logger.warn("[POST /movies/import-api-detail] imdbID '{}'에 해당하는 영화 정보를 API에서 찾을 수 없습니다.", imdbId);
            model.addAttribute("errorMessage", "영화 상세 정보를 찾을 수 없습니다.");
            return "redirect:/search?error=detailNotFound";
        }
    }



	 // read-one: 특정 영화 상세 정보 조회
    // 25.08.02 coco030 영화 상세 정보 조회
    @GetMapping("/movies/{id}")
    @Transactional(readOnly = true)
    public String detail(@PathVariable Long id, Model model, HttpSession session) {
        logger.info("[GET /movies/{}] 영화 상세 정보 요청: ID = {}", id, id);
        movie movie = movieService.findById(id); 
       
        if (movie == null) {
            logger.warn("[GET /movies/{}] ID {}에 해당하는 영화가 DB에 없습니다. 목록으로 리다이렉트.", id, id);
            return "redirect:/movies?error=notFound";
        }
        
         // 찜 상태
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            boolean isLiked = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
            movie.setIsLiked(isLiked); // ✅ isLiked만 넣어줌
            logger.debug("상세 페이지 - 영화 '{}' (ID: {})의 찜 상태: {}", movie.getTitle(), movie.getId(), isLiked);
        } else {
            movie.setIsLiked(false);
        }
	     
        double avgHorror = userReviewService.getAverageHorrorScore(id);
        double avgSexual = userReviewService.getAverageSexualScore(id);     
        model.addAttribute("avgHorrorScore", avgHorror);
        model.addAttribute("avgSexualScore", avgSexual);
        System.out.println("평균 호러/평균 선정성 값 :" + avgHorror + avgSexual);

        List<UserReview> reviewList = userReviewService.getReviewsByMovie(id);
        model.addAttribute("reviewList", reviewList);
        System.out.println("리뷰 전체 리스트");
        
        // 25.08.02 coco030 영화 통계 정보 가져오기
        // 영화 통계 정보 가져오기
        StatDTO stat = statRepository.findMovieStatsById(id);
        List<String> genres = statRepository.findGenresByMovieId(id);
        stat.setGenres(genres);

     // 추천 영화 리스트 - 로그인 상태에 따라 분기 처리
        List<StatDTO> recommended;
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            // 로그인한 사용자: 취향 기반 추천
            recommended = statService.recommendForLoggedInUser(id, loginMember.getId());
            
            // 사용자 취향 편차 점수도 모델에 추가 (선택사항 - 디버깅용)
            Map<String, Double> userTasteScores = statService.calculateUserDeviationScores(loginMember.getId());
            model.addAttribute("userTasteScores", userTasteScores);
            
            logger.info("로그인 사용자 {}의 취향 기반 추천 영화 {} 개 조회 완료", 
                        loginMember.getId(), recommended.size());
        } else {
            // 비로그인 사용자: 기존 게스트 추천
            recommended = statService.recommendForGuest(id);
            
            logger.info("비로그인 사용자를 위한 게스트 추천 영화 {} 개 조회 완료", 
                        recommended.size());
        }

        // JSP 전달
        model.addAttribute("stat", stat); 
        model.addAttribute("recommended", recommended); 
        model.addAttribute("movie", movie); 
        System.out.println("영화 지표 및 통계 정보  :" + stat);
        System.out.println("========추천 영화 개수  :" + recommended.size()+ "==========");
        System.out.println("========추천된 영화  :" + recommended + "==========");
        
        List<Map<String, Object>> dbCastList = actorRepository.findCastAndCrewByMovieId(id);
        model.addAttribute("dbCastList", dbCastList);
        System.out.println("DB 출연진 리스트");

        Integer tmdbId = tmdbApiService.getTmdbMovieId(movie.getApiId());
        List<Map<String, String>> tmdbCastList = tmdbApiService.getCastAndCrew(tmdbId);
        model.addAttribute("tmdbCastList", tmdbCastList);
        System.out.println("TMDB 실시간 출연진 (API)");

        Map<String, List<String>> castInfo = new HashMap<>();
        for (Map<String, String> cast : tmdbCastList) {
            String type = cast.get("roleType"); 
            String name = cast.get("name");
            castInfo.computeIfAbsent(type, k -> new ArrayList<>()).add(name);
            System.out.println(" TMDB 그룹핑");
        }
        model.addAttribute("castInfo", castInfo);
        System.out.println("출연진 정보");

        List<MovieImage> movieImages = movieImageService.getImagesForMovie(movie.getId(), movie.getApiId());
        logger.info("[이미지 갤러리] 영화 ID: {}, API ID: {}, 가져온 이미지 수: {}", 
            movie.getId(), movie.getApiId(), movieImages.size());
        if (!movieImages.isEmpty()) {
            logger.debug("첫 번째 이미지 URL: {}", movieImages.get(0).getImageUrl());
        }
        System.out.println("[DEBUG] 이미지 갤러리 호출 결과 - movieId: " + movie.getId()
            + ", apiId: " + movie.getApiId() + ", 이미지 개수: " + movieImages.size());
        model.addAttribute("movieImages", movieImages);
        System.out.println("갤러리 스틸컷 :" + movieImages);

        List<InsightMessage> insights = statService.generateInsights(id);
        model.addAttribute("insights", insights);
        model.addAttribute("movie", movie);
        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("[GET /movies/{}] movieService.findById({}) 호출 완료.", id, id);
        System.out.println("통계 분석 메시지  :" + insights);

        logger.debug("상세 페이지 로드 - 영화 ID: {}, 제목: '{}', DB에서 가져온 likeCount: {}", 
                movie.getId(), movie.getTitle(), movie.getLikeCount());
      

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
    
    
    @GetMapping("/movies/all-recent") 
    @Transactional(readOnly = true)
    public String allRecentMovies(Model model, HttpSession session) {
        logger.info("[GET /movies/all-recent] 모든 최근 등록 영화 목록 요청.");

        List<movie> allRecentMovies = movieService.getAllRecentMovies(); 

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            logger.debug("로그인된 일반 회원 ({})의 전체 최근 영화 목록 찜 상태 반영 시작.", loginMember.getId());
            for (movie movie : allRecentMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 영화 ID: {}, 제목: '{}', 찜 상태: {}", movie.getId(), movie.getTitle(), isMovieLikedByCurrentUser);
            }
            logger.debug("로그인된 일반 회원 ({})의 전체 최근 영화 목록 찜 상태 반영 완료.", loginMember.getId());
        } else {
            logger.debug("비로그인 또는 관리자 계정으로 전체 최근 영화 목록 요청. 찜 상태 미반영.");
        }

        model.addAttribute("recentMovies", allRecentMovies);
        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("[GET /movies/all-recent] movieService.getAllRecentMovies() 호출 완료.");
        return "movie/recentMoviesList"; 
    }


    @GetMapping("/movies/all-upcoming")
    @Transactional(readOnly = true)
    public String allUpcomingMovies(Model model, HttpSession session) {
        logger.info("[GET /movies/all-upcoming] 모든 개봉 예정 영화 목록 요청.");

        List<movie> allUpcomingMovies = movieService.getAllUpcomingMovies();

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            logger.debug("모든 개봉 예정작 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 시작.", loginMember.getId());
            for (movie movie : allUpcomingMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser);
            }
            logger.debug("모든 개봉 예정작 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId());
        } else {
            logger.debug("모든 개봉 예정작 페이지 - 비로그인 또는 관리자 계정으로 찜 상태 미반영.");
        }

        model.addAttribute("upcomingMovies", allUpcomingMovies);
        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("[GET /movies/all-upcoming] 모든 개봉 예정작 데이터 로딩 완료.");
        return "movie/upcomingMoviesList";
    }

    @GetMapping("/movies/all-recommended")
    @Transactional(readOnly = true)
    public String allRecommendedMovies(Model model, HttpSession session) {
        logger.info("[GET /movies/all-recommended] 모든 찜 랭킹 영화 목록 요청.");

        List<movie> allRecommendedMovies = movieService.getAllRecommendedMovies();

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            logger.debug("모든 찜 랭킹 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 시작.", loginMember.getId());
            for (movie movie : allRecommendedMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser);
            }
            logger.debug("모든 찜 랭킹 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId());
        } else {
            logger.debug("모든 찜 랭킹 페이지 - 비로그인 또는 관리자 계정으로 찜 상태 미반영.");
        }

        model.addAttribute("recommendedMovies", allRecommendedMovies);
        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("[GET /movies/all-recommended] 모든 찜 랭킹 영화 데이터 로딩 완료.");
        return "movie/recommendedMoviesList"; 
    }
    
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
                }
                // imdbId로 Tmdb 출연진 조회
                String imdbIdForTmdb = externalMovieDetail.getApiId();
                Integer tmdbId = tmdbApiService.getTmdbMovieId(imdbIdForTmdb);
                if (tmdbId != null) {
                    List<Map<String, String>> castAndCrew = tmdbApiService.getCastAndCrew(tmdbId);
                    model.addAttribute("castAndCrew", castAndCrew);
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

    private void overrideRatingsWithLocalData(List<movie> apiMovies) {
        for (movie apiMovie : apiMovies) {
            movie localMovie = movieService.findByApiId(apiMovie.getApiId());
            if (localMovie != null) {
                apiMovie.setRating(localMovie.getRating());
                apiMovie.setViolence_score_avg(localMovie.getViolence_score_avg());
                apiMovie.setId(localMovie.getId());
                apiMovie.setLikeCount(localMovie.getLikeCount());
                logger.debug("영화 '{}' (apiId: {})의 평점/잔혹도/찜개수를 로컬 DB 데이터로 덮어씀.", apiMovie.getTitle(), apiMovie.getApiId());
            } else {
                logger.debug("영화 '{}' (apiId: {})는 로컬 DB에 없어 API 평점/잔혹도/찜개수 유지.", apiMovie.getTitle(), apiMovie.getApiId());
                apiMovie.setLikeCount(0);
            }
        }
    }

    @GetMapping("/accessDenied")
    public String accessDenied() {
        return "accessDenied";
    }


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
        logger.info("영화 '{}' 업데이트 완료.", movie.getTitle());
        return "redirect:/movies";
    }

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

    @GetMapping("/admin/banner-movies")
    public String adminBannerMovies(Model model, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[GET /admin/banner-movies] 권한 없음: 비관리자 접근 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[GET /admin/banner-movies] 관리자 수동 추천 영화 관리 페이지 요청.");
        List<movie> allMovies = movieService.findAll();
        List<movie> currentAdminBannerMovies = adminBannerMovieService.getAdminRecommendedMovies();

        model.addAttribute("allMovies", allMovies);
        model.addAttribute("currentAdminBannerMovies", currentAdminBannerMovies);
        model.addAttribute("userRole", session.getAttribute("userRole"));
        return "admin/bannerMovieManage";
    }
    @PostMapping("/admin/banner-movies/add")
    public String addBannerMovie(@RequestParam("movieId") Long movieId, RedirectAttributes redirectAttributes, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[POST /admin/banner-movies/add] 권한 없음: 비관리자 추천 영화 추가 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /admin/banner-movies/add] 수동 추천 영화 추가 요청: Movie ID = {}", movieId);

        try {
            if (adminBannerMovieService.isMovieInAdminBanner(movieId)) {
                redirectAttributes.addFlashAttribute("errorMessage", "이미 수동 추천 영화로 등록된 영화입니다.");
                return "redirect:/admin/banner-movies";
            }

            adminBannerMovieService.addAdminRecommendedMovie(movieId);
            redirectAttributes.addFlashAttribute("successMessage", "영화가 수동 추천 배너에 추가되었습니다.");
        } catch (Exception e) {
            logger.error("수동 추천 영화 추가 실패 (movieId={}): {}", movieId, e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "수동 추천 영화 추가 중 오류가 발생했습니다.");
        }
        return "redirect:/admin/banner-movies";
    }

    @PostMapping("/admin/banner-movies/delete")
    public String deleteBannerMovie(@RequestParam("movieId") Long movieId, RedirectAttributes redirectAttributes, HttpSession session) {
        if (!isAdmin(session)) {
            logger.warn("[POST /admin/banner-movies/delete] 권한 없음: 비관리자 추천 영화 삭제 시도.");
            return "redirect:/accessDenied";
        }
        logger.info("[POST /admin/banner-movies/delete] 수동 추천 영화 삭제 요청: Movie ID = {}", movieId);

        try {
            adminBannerMovieService.removeAdminRecommendedMovie(movieId);
            redirectAttributes.addFlashAttribute("successMessage", "영화가 수동 추천 배너에서 삭제되었습니다.");
        } catch (Exception e) {
            logger.error("수동 추천 영화 삭제 실패 (movieId={}): {}", movieId, e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "수동 추천 영화 삭제 중 오류가 발생했습니다.");
        }
        return "redirect:/admin/banner-movies";
    }
   
    @GetMapping("/movies/upcoming")
    public String showUpcomingMovies(Model model) {
        System.out.println("업커밍");
        List<movie> upcomingMovies = movieService.getUpcomingMoviesWithDday();
        model.addAttribute("upcomingMovies", upcomingMovies);
        return "movie/upcomingMovies";
    }

    @GetMapping("/movies/commentCard")
    public String commentCard(Model model, HttpSession session) {
        List<RecentCommentDTO> recentComments = movieService.getRecentComments();
        model.addAttribute("recentComments", recentComments);
        return "movie/comment-card";
    }
    
}