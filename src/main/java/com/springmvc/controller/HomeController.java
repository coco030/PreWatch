// src/main/java/com/springmvc/controller/HomeController.java
package com.springmvc.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.springmvc.domain.Member;
import com.springmvc.domain.RecentCommentDTO;
import com.springmvc.domain.StatDTO;
import com.springmvc.domain.movie;
import com.springmvc.service.AdminBannerMovieService;
import com.springmvc.service.GlobalStatService;
import com.springmvc.service.movieService;
import com.springmvc.service.userCartService;

@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    private final movieService movieService;
    private final AdminBannerMovieService adminBannerMovieService;
    private final userCartService userCartService;

    @Autowired
    public HomeController(movieService movieService, AdminBannerMovieService adminBannerMovieService, userCartService userCartService) {
        this.movieService = movieService;
        this.adminBannerMovieService = adminBannerMovieService;
        this.userCartService = userCartService;
    }
    
    @Autowired
    private GlobalStatService statisticsService;

    @GetMapping("/")
    public String home(Model model, HttpSession session) {
        logger.info("루트 경로 '/' 요청이 감지되었습니다. 메인 홈페이지 데이터를 불러옵니다.");

        // 1. 최근 등록된 영화 목록 가져오기 (상위 3개)
        List<movie> recentMovies = movieService.getRecentMovies(3);
        model.addAttribute("movies", recentMovies);

        // 2. PreWatch 추천 랭킹 영화 목록 가져오기 (like_count 기준 상위 5개)
        List<movie> recommendedMovies = movieService.getTop6RecommendedMovies();
        model.addAttribute("recommendedMovies", recommendedMovies);

        // 3. 관리자 수동 추천 영화 목록 가져오기 (새로운 배너용)
        List<movie> adminRecommendedMovies = adminBannerMovieService.getAdminRecommendedMovies();
        model.addAttribute("adminRecommendedMovies", adminRecommendedMovies);

        // 07.26 coco030 오후 3시 20분 - 최근 개봉 예정작
        List<movie> upcomingMovies = movieService.getUpcomingMoviesWithDday();
        model.addAttribute("upcomingMovies", upcomingMovies);

        // ⭐⭐⭐ 7. 최근 등록된 평가된 평가와 댓글 섹션 데이터 추가 ⭐⭐⭐
        List<RecentCommentDTO> recentComments = movieService.getRecentComments();
        model.addAttribute("recentComments", recentComments);
        logger.debug("HomeController: 'recentComments' 모델에 {}개의 코멘트 추가됨.", recentComments.size());
        if (!recentComments.isEmpty()) {
            recentComments.forEach(comment -> logger.debug("  - 모델에 추가된 코멘트 (HomeController): {}", comment.getMovieName()));
        }
        // ⭐⭐⭐ 여기까지 추가 ⭐⭐⭐
        
     // 25.07.28 coco030 통계 객체를 메서드 안에서 가져오고 모델에 담기
        StatDTO globalStats = statisticsService.getGlobalStats();
        model.addAttribute("globalStats", globalStats);


     // 모든 영화 목록에 대해 찜 상태 반영
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            logger.debug("홈 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 시작.", loginMember.getId());
            // recentMovies 찜 상태 반영
            for (movie movie : recentMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 최근 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser);
            }
            // recommendedMovies 찜 상태 반영
            for (movie movie : recommendedMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 추천 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser);
            }
            // adminRecommendedMovies 찜 상태 반영
            for (movie movie : adminRecommendedMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 관리자 추천 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser);
            }
            // upcomingMovies 찜 상태 반영
            for (movie movie : upcomingMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 개봉 예정 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser);
            }
            logger.debug("홈 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId());
        } else {
            logger.debug("홈 페이지 - 비로그인 또는 관리자 계정으로 찜 상태 미반영.");
        }

        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.info("홈 뷰 진입");
        return "home"; // 뷰 이름이 "home"임을 확인했습니다.
    }

    // 25.07.28 위치 옮김. globalStats 통계 컨트롤러
    @ControllerAdvice
    public class GlobalControllerAdvice {
        @Autowired
        private GlobalStatService statisticsService;
        // 모든 컨트롤러의 메서드가 실행되기 전에 호출. 반환된 값은 "globalStats"라는 이름으로 모델에 추가.
        @ModelAttribute("globalStats")
        public StatDTO addGlobalStatsToModel() {
            return statisticsService.getGlobalStats();
        }
    }


}