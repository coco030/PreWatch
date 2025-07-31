package com.springmvc.repository; // <-- CalendarUtil의 실제 패키지

import com.springmvc.service.movieService; // movieService의 패키지 확인
import com.springmvc.domain.movie;       // movie의 실제 패키지
import com.springmvc.domain.CalendarData; // ⭐ CalendarData의 실제 패키지 ⭐

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component; // @Component 유지 (스프링 빈으로 등록 위함)

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component // 스프링 빈으로 등록되어야 HomeController에서 주입 가능
public class CalendarUtil {

    private static final Logger logger = LoggerFactory.getLogger(CalendarUtil.class);

    private final movieService movieService;

    @Autowired
    public CalendarUtil(movieService movieService) {
        this.movieService = movieService;
    }

    public List<List<CalendarData>> generateCalendarData(int year, int month) {
        logger.info("generateCalendarData 호출: year={}, month={}", year, month);

        List<List<CalendarData>> calendarWeeks = new ArrayList<>();
        LocalDate today = LocalDate.now();
        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDate firstDayOfMonth = yearMonth.atDay(1);
        LocalDate lastDayOfMonth = yearMonth.atEndOfMonth();

        logger.debug("movieService.getUpcomingMoviesForMonth 호출 시도: year={}, month={}", year, month);
        Map<LocalDate, List<movie>> upcomingMoviesByDate = movieService.getUpcomingMoviesForMonth(year, month);
        logger.debug("movieService.getUpcomingMoviesForMonth 반환: {}개 날짜에 영화 정보 있음.", upcomingMoviesByDate.size());

        int dayOfWeekValue = firstDayOfMonth.getDayOfWeek().getValue(); // 1(월) ~ 7(일)
        int startDayOfWeek = (dayOfWeekValue == 7) ? 0 : dayOfWeekValue; // 일요일이면 0, 월요일이면 1...

        LocalDate currentDay = firstDayOfMonth.minusDays(startDayOfWeek);
        logger.debug("달력 시작 날짜 (currentDay): {}", currentDay);

        for (int i = 0; i < 6; i++) {
            List<CalendarData> week = new ArrayList<>();
            for (int j = 0; j < 7; j++) {
                boolean isCurrentMonth = currentDay.getMonthValue() == month && currentDay.getYear() == year;
                boolean isToday = currentDay.isEqual(today);

                CalendarData calendarData = new CalendarData(currentDay, isCurrentMonth, isToday);
                logger.debug("  - CalendarData 생성: Date={}, isCurrentMonth={}, isToday={}",
                             calendarData.getDate(), calendarData.getCurrentMonthStatus(), calendarData.getTodayStatus());

                List<movie> moviesOnThisDay = upcomingMoviesByDate.get(currentDay);
                if (moviesOnThisDay != null && !moviesOnThisDay.isEmpty()) {
                    calendarData.setMovies(moviesOnThisDay);
                    logger.debug("  - 날짜 {}에 영화 {}개 추가됨.", currentDay, moviesOnThisDay.size());
                } else {
                    logger.debug("  - 날짜 {}에 영화 없음.", currentDay);
                }
                week.add(calendarData);
                currentDay = currentDay.plusDays(1);
            }
            calendarWeeks.add(week);
        }
        logger.info("generateCalendarData 완료: {}주 데이터 생성.", calendarWeeks.size());
        return calendarWeeks;
    }
}