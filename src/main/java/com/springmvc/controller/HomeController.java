// src/main/java/com/springmvc/controller/HomeController.java
package com.springmvc.controller;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.springmvc.domain.CalendarData;
import com.springmvc.domain.Member;
import com.springmvc.domain.StatDTO;
import com.springmvc.domain.movie;
import com.springmvc.repository.CalendarUtil; // 07-31: CalendarUtil의 실제 패키지 확인
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
    private final CalendarUtil calendarUtil; // 07-31: CalendarUtil 필드 추가

    @Autowired
    private GlobalStatService statisticsService;

    @Autowired
    public HomeController(movieService movieService,
                          AdminBannerMovieService adminBannerMovieService,
                          userCartService userCartService,
                          CalendarUtil calendarUtil) { // 07-31: CalendarUtil 파라미터 추가
        this.movieService = movieService;
        this.adminBannerMovieService = adminBannerMovieService;
        this.userCartService = userCartService;
        this.calendarUtil = calendarUtil; // 07-31: CalendarUtil 초기화
    }

    @GetMapping("/")
    public String home(Model model,
                       HttpSession session,
                       @RequestParam(value = "year", required = false) Integer year,
                       @RequestParam(value = "month", required = false) Integer month) {
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
     
        // 07-31: 달력 관련 로직 (초기 페이지 로드 시 Model에 데이터 담기)
        LocalDate today = LocalDate.now();
        int currentYear = (year != null) ? year : today.getYear();
        int currentMonth = (month != null) ? month : today.getMonthValue();

        List<List<CalendarData>> calendarWeeks = calendarUtil.generateCalendarData(currentYear, currentMonth);

        YearMonth yearMonth = YearMonth.of(currentYear, currentMonth);

        model.addAttribute("currentYear", currentYear);
        model.addAttribute("currentMonth", currentMonth);
        model.addAttribute("today", today);
        model.addAttribute("calendarWeeks", calendarWeeks);

        model.addAttribute("prevMonthYear", yearMonth.minusMonths(1).getYear());
        model.addAttribute("prevMonth", yearMonth.minusMonths(1).getMonthValue());
        model.addAttribute("nextMonthYear", yearMonth.plusMonths(1).getYear());
        model.addAttribute("nextMonth", yearMonth.plusMonths(1).getMonthValue());
        // 07-31: 달력 관련 로직 끝
        
     // 25.07.28 coco030 통계 객체를 메서드 안에서 가져오고 모델에 담기
        StatDTO globalStats = statisticsService.getGlobalStats();
        model.addAttribute("globalStats", globalStats);


        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            logger.debug("홈 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 시작.", loginMember.getId());
            for (movie movie : recentMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
            }
            for (movie movie : recommendedMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
            }
            for (movie movie : adminRecommendedMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
            }
            for (movie movie : upcomingMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
            }
            logger.debug("홈 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId());
        } else {
            logger.debug("홈 페이지 - 비로그인 또는 관리자 계정으로 찜 상태 미반영.");
        }

        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.info("홈 뷰 진입");
        return "home";
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