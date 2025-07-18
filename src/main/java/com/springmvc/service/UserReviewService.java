package com.springmvc.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.springmvc.domain.UserReview;
import com.springmvc.repository.UserReviewRepository;
import com.springmvc.repository.movieRepository;


@Service
public class UserReviewService {
    
	@Autowired
	private UserReviewService userReviewService;
	
    @Autowired
    private UserReviewRepository userReviewRepository;
    
    @Autowired
    private movieRepository movieRepository;
    
    // 리뷰 저장/수정
    public void saveReview(UserReview review) {
    	System.out.println("▶ 리뷰 저장 서비스 페이지 진입");
        userReviewRepository.saveOrUpdate(review);

        // 추가: 리뷰 저장 후 평균 점수 계산해서 영화 테이블에 반영
        Long movieId = review.getMovieId();
        double avgRating = getAverageRating(movieId);
        double avgViolence = getAverageViolenceScore(movieId);
        System.out.println("계산된 평균 평점: " + avgRating);
        System.out.println("계산된 평균 잔혹도: " + avgViolence);
        movieRepository.updateAverageScores(movieId, avgRating, avgViolence);
    }
    
    // 영화별 리뷰 목록 조회
    public List<UserReview> getReviewsByMovie(Long movieId) {
    	System.out.println("▶ 영화별 리뷰 목록 조회 영화 아이디: " + movieId);
        return userReviewRepository.findByMovieId(movieId);
    }
    
    // 내가 쓴 리뷰 조회
    public UserReview getMyReview(String memberId, Long movieId) {
        return userReviewRepository.findByMemberIdAndMovieId(memberId, movieId);
    }
    
    // 영화 평균 만족도 별점 조회
    public Double getAverageRating(Long movieId) {
        Double avg = userReviewRepository.getAverageRating(movieId);
        return avg != null ? Math.round(avg * 10) / 10.0 : 0.0; // 반올림 하는거
    }
    
    // 영화 평균 폭력성 점수 조회
    public Double getAverageViolenceScore(Long movieId) {
        Double avg = userReviewRepository.getAverageViolenceScore(movieId);
        return avg != null ? Math.round(avg * 10) / 10.0 : 0.0; // 반올림 하는거
    }
  // 마이페이지에서 사용자가 작성한 모든 리뷰 조회 뷰
    public List<UserReview> getMyReviews(String memberId) {
        return userReviewRepository.findAllByMemberId(memberId);
    }
}