package com.springmvc.service;

import com.springmvc.domain.StatDTO;
import com.springmvc.domain.UserReviewScoreDTO;
import com.springmvc.domain.TasteAnalysisDataDTO;
import com.springmvc.repository.StatRepository;
import com.springmvc.repository.UserReviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class MovieStatService {

    @Autowired
    private StatRepository statRepository;

    @Autowired
    private UserReviewRepository userReviewRepository;

    // 1. 특정 영화의 장르 목록 가져오기
    public List<String> getGenresByMovieId(long movieId) {
        return statRepository.findGenresByMovieId(movieId);
    }

    // 2. 특정 영화의 통계 정보 가져오기
    public StatDTO getMovieStatsById(long movieId) {
        return statRepository.findMovieStatsById(movieId);
    }

    // 3. 특정 장르의 평균 점수 계산하기
    public StatDTO getGenreAverageScores(String genre) {
        return statRepository.getGenreAverageScores(genre);
    }

    // 4. 특정 사용자가 작성한 리뷰의 점수 분석
    public List<UserReviewScoreDTO> getUserReviewScoresForAnalysis(String memberId) {
        return statRepository.findUserReviewScoresForAnalysis(memberId);
    }

    // 5. 사용자의 취향 분석 데이터 가져오기
    public List<TasteAnalysisDataDTO> getTasteAnalysisData(String memberId) {
        return statRepository.findTasteAnalysisData(memberId);
    }

    // 6. 영화의 평균 만족도 점수 계산
    public Double getAverageRating(Long movieId) {
        return statRepository.getAverageRating(movieId);
    }

    // 7. 영화의 평균 폭력성 점수 계산
    public Double getAverageViolenceScore(Long movieId) {
        return statRepository.getAverageViolenceScore(movieId);
    }

    // 8. 영화의 평균 공포성 점수 계산
    public Double getAverageHorrorScore(Long movieId) {
        return statRepository.getAverageHorrorScore(movieId);
    }

    // 9. 영화의 평균 선정성 점수 계산
    public Double getAverageSexualScore(Long movieId) {
        return statRepository.getAverageSexualScore(movieId);
    }

    // 10. 저장된 평균 공포성 점수 조회
    public Double getSavedAverageHorrorScore(Long movieId) {
        return statRepository.getSavedAverageHorrorScore(movieId);
    }

    // 11. 저장된 평균 선정성 점수 조회
    public Double getSavedAverageSexualScore(Long movieId) {
        return statRepository.getSavedAverageSexualScore(movieId);
    }

    // 12. 특정 사용자가 평가한 영화들의 평균 만족도 점수 계산
    public Double getAverageUserRatingByMemberId(String memberId) {
        return userReviewRepository.getAverageUserRatingByMemberId(memberId);
    }

    // 13. 특정 사용자가 평가한 영화들의 평균 폭력성 점수 계산
    public Double getAverageViolenceScoreByMemberId(String memberId) {
        return userReviewRepository.getAverageViolenceScoreByMemberId(memberId);
    }

    // 14. 특정 사용자가 평가한 각 장르별 긍정적인 평가 횟수 계산
    public Map<String, Integer> getPositiveRatingGenreCounts(String memberId) {
        return userReviewRepository.getPositiveRatingGenreCounts(memberId);
    }

    // 15. 특정 사용자가 평가한 각 장르별 부정적인 평가 횟수 계산
    public Map<String, Integer> getNegativeRatingGenreCounts(String memberId) {
        return userReviewRepository.getNegativeRatingGenreCounts(memberId);
    }

    // 16. 특정 사용자가 평가한 별점 분포 (히스토그램) 계산
    public Map<Integer, Integer> getRatingDistribution(String memberId) {
        return userReviewRepository.getRatingDistribution(memberId);
    }

    // 17. 특정 사용자가 각 장르에 대해 평가한 평균 점수 계산
    public Map<String, Double> getGenreAverageRatings(String memberId) {
        return userReviewRepository.getGenreAverageRatings(memberId);
    }

}
