package com.springmvc.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.springmvc.domain.Member;
import com.springmvc.domain.UserReview;
import com.springmvc.service.UserReviewService;

@Controller
@RequestMapping("/review")
public class ReviewController {
    
    @Autowired
    private UserReviewService userReviewService;
    
    // 리뷰 저장 (별점, 폭력성, 리뷰, 태그 통합)
    @PostMapping("/save")  // → /review/save
    @ResponseBody
    public ResponseEntity<?> saveReview(@RequestParam Long movieId,
                                      @RequestParam(required = false) Integer userRating,
                                      @RequestParam(required = false) Integer violenceScore,
                                      @RequestParam(required = false) String reviewContent,
                                      @RequestParam(required = false) String tags,
                                      HttpSession session) {
        
        // 세션에서 로그인 멤버 정보 가져오기
        Object loginMemberObj = session.getAttribute("loginMember");
        if (loginMemberObj == null) {
            return ResponseEntity.badRequest().body("로그인이 필요합니다.");
        }
        
        Member loginMember = (Member) loginMemberObj;
        String memberId = loginMember.getId();
        
        UserReview review = new UserReview(memberId, movieId, userRating, violenceScore, reviewContent, tags);
        
        userReviewService.saveReview(review);
        
        // 업데이트된 평균 점수 반환
        Map<String, Object> response = new HashMap<>();
        response.put("avgRating", userReviewService.getAverageRating(movieId));
        response.put("avgViolence", userReviewService.getAverageViolenceScore(movieId));
        response.put("success", true);
        
        return ResponseEntity.ok(response);
    }
    
    // 내가 쓴 리뷰 조회
    @GetMapping("/my/{movieId}")  // → /review/my/{movieId}
    @ResponseBody
    public ResponseEntity<UserReview> getMyReview(@PathVariable Long movieId, 
                                                HttpSession session) {
        Object loginMemberObj = session.getAttribute("loginMember");
        if (loginMemberObj == null) {
            return ResponseEntity.badRequest().build();
        }
        
        Member loginMember = (Member) loginMemberObj;
        String memberId = loginMember.getId();
        
        UserReview review = userReviewService.getMyReview(memberId, movieId);
        return ResponseEntity.ok(review);
    }
    
    // 영화별 리뷰 목록 조회
    @GetMapping("/movie/{movieId}")  // → /review/movie/{movieId}
    @ResponseBody
    public ResponseEntity<List<UserReview>> getMovieReviews(@PathVariable Long movieId) {
        List<UserReview> reviews = userReviewService.getReviewsByMovie(movieId);
        return ResponseEntity.ok(reviews);
    }
    
    // 영화 평균 점수 조회      /review/avg/{movieId}
    @GetMapping("/avg/{movieId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getAverageScores(@PathVariable Long movieId) {
        Map<String, Object> response = new HashMap<>();

        // 평균
        response.put("avgRating", userReviewService.getAverageRating(movieId));
        response.put("avgViolence", userReviewService.getAverageViolenceScore(movieId));

        return ResponseEntity.ok(response);
    }
    
    //영화 만족도 평점 (아작스 처리용이라 현재는 쉬는 중)
//    @GetMapping("/rating")
//    public String loadRatingModule(@RequestParam("movieId") Long movieId, Model model) {
//        model.addAttribute("movieId", movieId);
//        return "reviewModule/01_rating";
//    }
    
    //리뷰폼 합친 것 여기서 평점 입력/리뷰/태그 다 입력함. 임시
    @GetMapping("/form")
    public String reviewForm(@RequestParam("movieId") Long movieId, Model model, HttpSession session) {
        model.addAttribute("movieId", movieId);

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null) {
            UserReview myReview = userReviewService.getMyReview(loginMember.getId(), movieId);
            model.addAttribute("myReview", myReview);
        }

        return "reviewModule/reviewForm";
    }

    
    // 리뷰를 뷰로 뿌려주기 
    @GetMapping("/list")
    public String listReviews(@RequestParam Long movieId, Model model, HttpSession session) {
        Member loginMember = (Member) session.getAttribute("loginMember");

        if (loginMember != null) {
            UserReview myReview = userReviewService.getMyReview(loginMember.getId(), movieId);
            model.addAttribute("myReview", myReview);
        }

        List<UserReview> reviewList = userReviewService.getReviewsByMovie(movieId);
        model.addAttribute("reviewList", reviewList);

        return "reviewModule/reviewList"; // → /WEB-INF/views/reviewModule/reviewList.jsp
    }
    
    // 모든 태그를 뷰로 뿌려주기
    @GetMapping("/tags")
    public String tagList(@RequestParam Long movieId, Model model) {
        List<UserReview> reviewList = userReviewService.getReviewsByMovie(movieId);
        model.addAttribute("reviewList", reviewList); // 태그만 뽑을 거라 리뷰 전체 보내면 됨
        return "reviewModule/reviewTagAll"; // 파일명 그대로
    }
}
