package com.springmvc.service;

import java.util.List;

import com.springmvc.service.StatServiceImpl.InsightMessage;

public interface StatService {
    void initializeMovieGenres();

	List<InsightMessage> generateInsights(long movieId);

}