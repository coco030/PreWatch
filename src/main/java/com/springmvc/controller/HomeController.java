// src/main/java/com/springmvc/controller/HomeController.java
package com.springmvc.controller;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.springmvc.domain.CalendarData;
import com.springmvc.domain.Member;
import com.springmvc.domain.RecentCommentDTO;
import com.springmvc.domain.StatDTO;
import com.springmvc.domain.Movie;
import com.springmvc.repository.CalendarUtil; // 07-31: CalendarUtil의 실제 패키지 확인
import com.springmvc.service.AdminBannerMovieService;
import com.springmvc.service.GlobalStatService;
import com.springmvc.service.MovieActivityService;
import com.springmvc.service.MovieService;
import com.springmvc.service.SearchActivityService;
import com.springmvc.service.UserCartService;

@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    private final MovieService movieService;
    private final AdminBannerMovieService adminBannerMovieService;
    private final UserCartService userCartService;
    private final CalendarUtil calendarUtil; // 07-31: CalendarUtil 필드 추가
    private final SearchActivityService searchActivityService;
    private final MovieActivityService movieActivityService;

    @Autowired
    private GlobalStatService statisticsService;

    @Autowired
    public HomeController(MovieService movieService,
                          AdminBannerMovieService adminBannerMovieService,
                          UserCartService userCartService,
                          CalendarUtil calendarUtil,
                          SearchActivityService searchActivityService,
                          MovieActivityService movieActivityService) { // 07-31: CalendarUtil 파라미터 추가
        this.movieService = movieService;
        this.adminBannerMovieService = adminBannerMovieService;
        this.userCartService = userCartService;
        this.calendarUtil = calendarUtil; // 07-31: CalendarUtil 초기화
        this.searchActivityService = searchActivityService;
        this.movieActivityService = movieActivityService;
    }

    @GetMapping("/")
    public String home(Model model,
                       HttpSession session,
                       @RequestParam(value = "year", required = false) Integer year,
                       @RequestParam(value = "month", required = false) Integer month) {
        logger.info("루트 경로 '/' 요청이 감지되었습니다. 메인 홈페이지 데이터를 불러옵니다.");

        // 1. 최근 등록된 영화 목록 가져오기 (상위 3개)
        List<Movie> recentMovies = movieService.getRecentMovies(3);
        model.addAttribute("movies", recentMovies);

        // 2. PreWatch 추천 랭킹 영화 목록 가져오기 (like_count 기준 상위 5개)
        List<Movie> recommendedMovies = movieService.getTop6RecommendedMovies();
        model.addAttribute("recommendedMovies", recommendedMovies);

        // 3. 관리자 수동 추천 영화 목록 가져오기 (새로운 배너용)
        List<Movie> adminRecommendedMovies = adminBannerMovieService.getAdminRecommendedMovies();
        model.addAttribute("adminRecommendedMovies", adminRecommendedMovies);

        List<RecentCommentDTO> recentComments = movieService.getRecentComments();
        model.addAttribute("recentComments", recentComments);
        model.addAttribute("recentSearchKeywords", searchActivityService.getRecentKeywords());
        model.addAttribute("recentViewedMovies", movieActivityService.getRecentViewedMovies());

        // 07.26 coco030 오후 3시 20분 - 최근 개봉 예정작
        List<Movie> upcomingMovies = movieService.getUpcomingMoviesWithDday();
        model.addAttribute("upcomingMovies", upcomingMovies);
     
     // 25.07.28 coco030 통계 객체를 메서드 안에서 가져오고 모델에 담기
        StatDTO globalStats = statisticsService.getGlobalStats();
        model.addAttribute("globalStats", globalStats);


        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            logger.debug("홈 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 시작.", loginMember.getId());
            Set<Long> likedMovieIds = userCartService.getLikedMovieIdSet(loginMember.getId());
            applyLikedStatus(recentMovies, likedMovieIds);
            applyLikedStatus(recommendedMovies, likedMovieIds);
            applyLikedStatus(adminRecommendedMovies, likedMovieIds);
            applyLikedStatus(upcomingMovies, likedMovieIds);
            logger.debug("홈 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId());
        } else {
            logger.debug("홈 페이지 - 비로그인 또는 관리자 계정으로 찜 상태 미반영.");
        }

        model.addAttribute("userRole", loginMember != null ? loginMember.getRole() : null);
        logger.info("홈 뷰 진입");
        return "home";
    }

    private void applyLikedStatus(List<Movie> movies, Set<Long> likedMovieIds) {
        for (Movie movie : movies) {
            movie.setIsLiked(movie.getId() != null && likedMovieIds.contains(movie.getId()));
        }
    }
    
// 07-31: AJAX 요청을 처리하는 캘린더 데이터 엔드포인트 (JSON 반환)
@GetMapping("/calendar/data")
@ResponseBody
public ResponseEntity<Map<String, Object>> getCalendarDataAjax(
        @RequestParam(value = "year", required = false) Integer year,
        @RequestParam(value = "month", required = false) Integer month) {

    logger.info("[GET /calendar/data] AJAX 캘린더 데이터 요청: year={}, month={}", year, month);

    LocalDate today = LocalDate.now();
    int currentYear = (year != null) ? year : today.getYear();
    int currentMonth = (month != null) ? month : today.getMonthValue();

    List<List<CalendarData>> calendarWeeks = calendarUtil.generateCalendarData(currentYear, currentMonth);

    YearMonth yearMonth = YearMonth.of(currentYear, currentMonth);

    Map<String, Object> response = new HashMap<>();
    response.put("currentYear", currentYear);
    response.put("currentMonth", currentMonth);
    response.put("today", today);
    response.put("calendarWeeks", calendarWeeks);
    response.put("prevMonthYear", yearMonth.minusMonths(1).getYear());
    response.put("prevMonth", yearMonth.minusMonths(1).getMonthValue());
    response.put("nextMonthYear", yearMonth.plusMonths(1).getYear());
    response.put("nextMonth", yearMonth.plusMonths(1).getMonthValue());

    logger.debug("AJAX 캘린더 데이터 반환 완료. ({} 주)", calendarWeeks.size());
    return ResponseEntity.ok(response);
	}
}







