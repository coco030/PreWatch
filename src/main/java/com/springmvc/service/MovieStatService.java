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

// 엉망이네 여차하면 버려
    
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
        // UserReviewRepository에서 계산된 평균 점수 가져오기
        Double avgRating = userReviewRepository.getAverageRating(movieId);
        return (avgRating != null) ? avgRating : 0.0; // null 처리
    }

    // 7. 영화의 평균 폭력성 점수 계산
    public Double getAverageViolenceScore(Long movieId) {
        // UserReviewRepository에서 계산된 평균 폭력성 점수 가져오기
        Double avgViolence = userReviewRepository.getAverageViolenceScore(movieId);
        return (avgViolence != null) ? avgViolence : 0.0; // null 처리
    }

    // 8. 영화의 평균 공포성 점수 계산
    public Double getAverageHorrorScore(Long movieId) {
        // UserReviewRepository에서 계산된 평균 공포성 점수 가져오기
        Double avgHorror = userReviewRepository.getAverageHorrorScore(movieId);
        return (avgHorror != null) ? avgHorror : 0.0; // null 처리
    }

    // 9. 영화의 평균 선정성 점수 계산
    public Double getAverageSexualScore(Long movieId) {
        // UserReviewRepository에서 계산된 평균 선정성 점수 가져오기
        Double avgSexual = userReviewRepository.getAverageSexualScore(movieId);
        return (avgSexual != null) ? avgSexual : 0.0; // null 처리
    }


    // 10. 저장된 평균 공포성 점수 조회
    public Double getSavedAverageHorrorScore(Long movieId) {
        StatDTO statDTO = statRepository.findMovieStatsById(movieId);
        return (statDTO != null && statDTO.getHorrorScoreAvg() != null) ? statDTO.getHorrorScoreAvg() : 0.0;
    }

    // 11. 저장된 평균 선정성 점수 조회
    public Double getSavedAverageSexualScore(Long movieId) {
        StatDTO statDTO = statRepository.findMovieStatsById(movieId);
        return (statDTO != null && statDTO.getSexualScoreAvg() != null) ? statDTO.getSexualScoreAvg() : 0.0;
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
