package com.springmvc.service;

import java.util.List;

import com.springmvc.domain.StatDTO;
import com.springmvc.service.StatServiceImpl.InsightMessage;

public interface StatService {
    void initializeMovieGenres();

	List<InsightMessage> generateInsights(long movieId);
	List<StatDTO> recommendForGuest(long baseMovieId);

}