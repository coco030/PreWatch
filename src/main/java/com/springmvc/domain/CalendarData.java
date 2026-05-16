package com.springmvc.domain;

import com.springmvc.domain.Movie;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class CalendarData {
    private LocalDate date;
    private boolean isCurrentMonth; // 필드 이름은 그대로 둡니다.
    private boolean isToday;        // 필드 이름은 그대로 둡니다.
    private List<Movie> movies;

    public CalendarData(LocalDate date, boolean isCurrentMonth, boolean isToday) {
        this.date = date;
        this.isCurrentMonth = isCurrentMonth;
        this.isToday = isToday;
        this.movies = new ArrayList<>();
    }

    // Getters and Setters
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    // ? isCurrentMonth() -> getCurrentMonthStatus()로 변경 ?
    public boolean getCurrentMonthStatus() { return isCurrentMonth; }
    public void setCurrentMonth(boolean currentMonth) { isCurrentMonth = currentMonth; }

    // ? isToday() -> getTodayStatus()로 변경 ?
    public boolean getTodayStatus() { return isToday; }
    public void setToday(boolean today) { isToday = today; }

    public List<Movie> getMovies() { return movies; }
    public void setMovies(List<Movie> movies) { this.movies = movies; }

    public void addMovie(Movie movie) {
        this.movies.add(movie);
    }
}






