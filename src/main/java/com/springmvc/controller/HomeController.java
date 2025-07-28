package com.springmvc.controller;

import java.util.List; // (7-24 오후12:41 추가 된 코드)

import javax.servlet.http.HttpSession; // (7-24 오후12:41 추가 된 코드)

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.springmvc.domain.GlobalStatsDTO;
import com.springmvc.domain.Member; // (7-24 오후12:41 추가 된 코드)
import com.springmvc.domain.movie; // (7-24 오후12:41 추가 된 코드)
import com.springmvc.service.AdminBannerMovieService; // ⭐ 새로 추가된 서비스 임포트 (7-24 오후12:41 추가 된 코드)
import com.springmvc.service.StatisticsService;
import com.springmvc.service.movieService;
import com.springmvc.service.userCartService; // ⭐ userCartService 임포트 (7-24 오후12:41 추가 된 코드)

@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    private final movieService movieService;
    private final AdminBannerMovieService adminBannerMovieService; // ⭐ 새로 추가된 서비스 필드 (7-24 오후12:41 추가 된 코드)
    private final userCartService userCartService; // ⭐ userCartService 필드 (7-24 오후12:41 추가 된 코드)

    @Autowired
    public HomeController(movieService movieService, AdminBannerMovieService adminBannerMovieService, userCartService userCartService) { // ⭐ 생성자에도 추가 (7-24 오후12:41 추가 된 코드)
        this.movieService = movieService;
        this.adminBannerMovieService = adminBannerMovieService; // ⭐ 초기화 (7-24 오후12:41 추가 된 코드)
        this.userCartService = userCartService; // ⭐ 초기화 (7-24 오후12:41 추가 된 코드)
    }
    @Autowired
    private StatisticsService statisticsService;

    @GetMapping("/")
    public String home(Model model, HttpSession session) {
        logger.info("루트 경로 '/' 요청이 감지되었습니다. 메인 홈페이지 데이터를 불러옵니다.");
        
     // 25.07.28 coco030 통계 객체를 메서드 안에서 가져오고 모델에 담기
        GlobalStatsDTO globalStats = statisticsService.getGlobalStats();
        model.addAttribute("globalStats", globalStats);
        

        // 1. 최근 등록된 영화 목록 가져오기 (상위 3개)
        List<movie> recentMovies = movieService.getRecentMovies(3);
        model.addAttribute("movies", recentMovies);

        // 2. PreWatch 추천 랭킹 영화 목록 가져오기 (like_count 기준 상위 5개)
        List<movie> recommendedMovies = movieService.getTop5RecommendedMovies();
        model.addAttribute("recommendedMovies", recommendedMovies);

        // 3. ⭐ 관리자 수동 추천 영화 목록 가져오기 (새로운 배너용) ⭐ (7-24 오후12:41 추가 된 코드)
        List<movie> adminRecommendedMovies = adminBannerMovieService.getAdminRecommendedMovies(); // (7-24 오후12:41 추가 된 코드)
        model.addAttribute("adminRecommendedMovies", adminRecommendedMovies); // (7-24 오후12:41 추가 된 코드)
        
        // 07.26 coco030 오후 3시 20분
        List<movie> upcomingMovies = movieService.getUpcomingMoviesWithDday();
        model.addAttribute("upcomingMovies", upcomingMovies);
        
        // 모든 영화 목록에 대해 찜 상태 반영 (7-24 오후12:41 추가 된 코드)
        Member loginMember = (Member) session.getAttribute("loginMember"); // (7-24 오후12:41 추가 된 코드)
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) { // (7-24 오후12:41 추가 된 코드)
            logger.debug("홈 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 시작.", loginMember.getId()); // (7-24 오후12:41 추가 된 코드)
            // recentMovies 찜 상태 반영 (7-24 오후12:41 추가 된 코드)
            for (movie movie : recentMovies) { // (7-24 오후12:41 추가 된 코드)
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId()); // (7-24 오후12:41 추가 된 코드)
                movie.setIsLiked(isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
                logger.debug("  - 최근 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
            } // (7-24 오후12:41 추가 된 코드)
            // recommendedMovies 찜 상태 반영 (7-24 오후12:41 추가 된 코드)
            for (movie movie : recommendedMovies) { // (7-24 오후12:41 추가 된 코드)
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId()); // (7-24 오후12:41 추가 된 코드)
                movie.setIsLiked(isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
                logger.debug("  - 추천 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
            } // (7-24 오후12:41 추가 된 코드)
            // adminRecommendedMovies 찜 상태 반영 (7-24 오후12:41 추가 된 코드)
            for (movie movie : adminRecommendedMovies) { // (7-24 오후12:41 추가 된 코드)
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId()); // (7-24 오후12:41 추가 된 코드)
                movie.setIsLiked(isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
                logger.debug("  - 관리자 추천 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser); // (7-24 오후12:41 추가 된 코드)
            } // (7-24 오후12:41 추가 된 코드)
            logger.debug("홈 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId()); // (7-24 오후12:41 추가 된 코드)
        } else { // (7-24 오후12:41 추가 된 코드)
            logger.debug("홈 페이지 - 비로그인 또는 관리자 계정으로 찜 상태 미반영."); // (7-24 오후12:41 추가 된 코드)
        } // (7-24 오후12:41 추가 된 코드)


        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.info("홈 뷰 진입");
        return "home"; // Assuming this is the main JSP
    }
    
    // 25.07.28 위치 옮김. globalStats 통계 컨트롤러
    @ControllerAdvice
    public class GlobalControllerAdvice {
        @Autowired
        private StatisticsService statisticsService;
        // 모든 컨트롤러의 메서드가 실행되기 전에 호출. 반환된 값은 "globalStats"라는 이름으로 모델에 추가.
        @ModelAttribute("globalStats")
        public GlobalStatsDTO addGlobalStatsToModel() {
            return statisticsService.getGlobalStats();
        }
    }

    
}