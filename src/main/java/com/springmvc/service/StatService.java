package com.springmvc.service;

import java.util.List;
import java.util.Map;

import com.springmvc.domain.StatDTO;
import com.springmvc.service.StatServiceImpl.InsightMessage;

public interface StatService {
    void initializeMovieGenres();
    public List<StatDTO> recommendForGuest(long movieId);

    List<InsightMessage> generateInsights(long movieId);
    Map<String, Double> calculateUserDeviationScores(String memberId);
    List<String> getAllowedRatingsForGuest(String rated);
    List<StatDTO> recommendForLoggedInUser(long movieId, String memberId);


}