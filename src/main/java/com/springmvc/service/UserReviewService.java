package com.springmvc.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.springmvc.domain.UserReview;
import com.springmvc.repository.UserReviewRepository;
import com.springmvc.repository.movieRepository;


@Service
public class UserReviewService {
	
	@Autowired
	private JdbcTemplate jdbcTemplate;
	
    @Autowired
    private UserReviewRepository userReviewRepository;
    
    @Autowired
    private movieRepository movieRepository;
    
    
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

    // 영화 만족도 리뷰 1개 저장
    public void saveUserRating(String memberId, Long movieId, int userRating) {
        userReviewRepository.saveOrUpdateRating(memberId, movieId, userRating);

        double avgRating = getAverageRating(movieId);
        double avgViolence = getAverageViolenceScore(movieId);

        movieRepository.updateAverageScores(movieId, avgRating, avgViolence);
    }
    // 폭력성 점수 1개 저장
    public void saveViolenceScore(String memberId, Long movieId, Integer violenceScore) {
        userReviewRepository.saveOrUpdateViolenceScore(memberId, movieId, violenceScore);

        double avgRating = getAverageRating(movieId);
        double avgViolence = getAverageViolenceScore(movieId);

        movieRepository.updateAverageScores(movieId, avgRating, avgViolence);
    }
    //1인 리뷰
	public void saveReviewContent(String memberId, Long movieId, String reviewContent) {
	    userReviewRepository.saveOrUpdateReviewContent(memberId, movieId, reviewContent);
	}
	// 1인 태그
	public void saveTag(String memberId, Long movieId, String tag) {
	    userReviewRepository.saveOrUpdateTag(memberId, movieId, tag);
	}

	   // 사용자 리뷰 페이징 조회
    public List<UserReview> getPagedReviews(String memberId, int page, int pageSize) {
        return userReviewRepository.getPagedReviews(memberId, page, pageSize);
    }

    // 사용자 리뷰 총 개수 조회
    public int getTotalReviewCount(String memberId) {
        return userReviewRepository.getTotalReviewCount(memberId);
    }

    // 사용자 리뷰 삭제하기
    public boolean deleteReview(String memberId, Long movieId) {
        return userReviewRepository.deleteByMemberIdAndMovieId(memberId, movieId); 
    }
    
    // 사용자가 자주 평가한 영화 장르

    public Map<String, Integer> getUserGenreStats(String memberId) {
        return userReviewRepository.getGenreCountsByMemberId(memberId);
    }
    
    // 사용자가 긍정적으로 평가한 장르
    public Map<String, Integer> getPositiveGenreStats(String memberId) {
        return userReviewRepository.getPositiveRatingGenreCounts(memberId);
    }

    public boolean deleteTag(String memberId, Long movieId, String tagToDelete) {
        UserReview review = userReviewRepository.findByMemberIdAndMovieId(memberId, movieId);
        if (review == null || review.getTags() == null) return false;

        String[] tags = review.getTags().split(",");
        List<String> tagList = new ArrayList<>();
        for (String tag : tags) {
            if (!tag.trim().equals(tagToDelete)) {
                tagList.add(tag.trim());
            }
        }

        String updatedTags = String.join(",", tagList);
        return userReviewRepository.updateTags(memberId, movieId, updatedTags);
    }


    

}