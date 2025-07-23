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
    
    // 리뷰 저장 (별점)
    @PostMapping("/saveRating")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveRating(@RequestParam Long movieId,
                                                          @RequestParam Integer userRating,
                                                          HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        System.out.println(">>> saveRating() 호출됨");
        Object loginMemberObj = session.getAttribute("loginMember");
        if (loginMemberObj == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.badRequest().body(response); // JSON 반환
        }

        Member loginMember = (Member) loginMemberObj;
        String memberId = loginMember.getId();

        userReviewService.saveUserRating(memberId, movieId, userRating);

        double avgRating = userReviewService.getAverageRating(movieId);
        double avgViolence = userReviewService.getAverageViolenceScore(movieId);

        response.put("avgRating", avgRating);
        response.put("avgViolence", avgViolence);
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
    
    // 영화 만족도 평점 
    @GetMapping("/rating")
    public String loadRatingForm(@RequestParam("movieId") Long movieId, Model model, HttpSession session) {
        model.addAttribute("movieId", movieId);

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null) {
            UserReview myReview = userReviewService.getMyReview(loginMember.getId(), movieId);
            model.addAttribute("myReview", myReview);
        }

        return "reviewModule/userRatingForm";
    }
    
 // 영화 폭력성 점수 입력
    @GetMapping("/violence")
    public String loadViolenceForm(@RequestParam("movieId") Long movieId, Model model, HttpSession session) {
        model.addAttribute("movieId", movieId);

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null) {
            UserReview myReview = userReviewService.getMyReview(loginMember.getId(), movieId);
            model.addAttribute("myReview", myReview);
        }

        return "reviewModule/violenceScoreForm";
    }
    
 // 영화 리뷰 내용 입력
    @GetMapping("/content")
    public String loadReviewContentForm(@RequestParam("movieId") Long movieId, Model model, HttpSession session) {
        model.addAttribute("movieId", movieId);

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null) {
            UserReview myReview = userReviewService.getMyReview(loginMember.getId(), movieId);
            model.addAttribute("myReview", myReview);
        }

        return "reviewModule/reviewContentForm";
    }
    
 // 영화 태그 입력
    @GetMapping("/tag")
    public String loadTagInputForm(@RequestParam("movieId") Long movieId, Model model, HttpSession session) {
        model.addAttribute("movieId", movieId);

        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null) {
            UserReview myReview = userReviewService.getMyReview(loginMember.getId(), movieId);
            model.addAttribute("myReview", myReview);
        }

        return "reviewModule/tagForm";
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
    
    //폭력성 주의문구 뷰로 뿌려주기
    @GetMapping("/sensitivity")
    public String getViolenceSensitivity(@RequestParam Long movieId, Model model) {
        // 이미 movie 객체에서 평균을 조회할 수 있으므로 별도 DB조회 불필요
        model.addAttribute("movieId", movieId);
        return "reviewModule/reviewSensitivity"; // → /WEB-INF/views/reviewModule/reviewSensitivity.jsp
    }
}
