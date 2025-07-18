/*
    파일명: MemberController.java
    설명:
        이 class는 회원(Member) 관련 기능을 처리하는 컨트롤러입니다.
        회원가입, 회원 정보 수정(비밀번호), 회원 탈퇴(비활성화), 마이페이지 등의 요청을 담당합니다.

    목적:
        사용자가 회원 정보를 관리(가입, 수정, 탈퇴)하고 개인화된 페이지(마이페이지)에 접근하기 위함.

*/

package com.springmvc.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.springmvc.domain.Member;
import com.springmvc.domain.UserReview;
import com.springmvc.domain.movie;
import com.springmvc.repository.movieRepository;
import com.springmvc.service.MemberService;
import com.springmvc.service.UserReviewService;

@Controller // Spring이 컨트롤러로 인식
@RequestMapping("/member") // 기본 URL 경로 "/member" 설정

public class MemberController {
	
	@Autowired
	private movieRepository movieRepository;
	@Autowired
    private UserReviewService userReviewService;
	
    @Autowired
    private MemberService memberService; // 회원 비즈니스 로직을 위임하기 위해 MemberService 주입

    // --- Read(all) Home ---
    // showHomePage 메서드: "/member/" 경로에 대한 GET 요청 처리
    // 목적: (HomeController가 메인을 담당하므로 현재는 역할 중복, 테스트/경로 확인용)
    @GetMapping("/")
    public String showHomePage() {
    	System.out.println("Membercontroller 메인 보여주기");
        return "home"; // "home.jsp" 뷰 반환
    }

    // --- Create ---
    // showJoinForm 메서드: "/member/join" 경로에 대한 GET 요청 처리
    // 목적: 회원가입 입력 폼을 사용자에게 보여주고, 폼 바인딩을 위해 빈 Member 객체 모델에 추가
    @GetMapping("/join")
    public String showJoinForm(Model model) {
    	System.out.println("Membercontroller 회원가입 폼 보여주기");
        model.addAttribute("member", new Member()); // 빈 Member 객체 추가
        return "joinForm"; // "joinForm.jsp" 뷰 반환
    }

    // processJoin 메서드: "/member/join" 경로에 대한 POST 요청 처리
    // 목적: 사용자 입력 회원 정보를 받아 회원가입 처리. ID 중복 시 에러 메시지 표시
    @PostMapping("/join")
    public String processJoin(@ModelAttribute Member member, Model model) {
    	System.out.println("[MemberController] 회원가입 처리 시도: id=" + member.getId());
        if (memberService.existsById(member.getId())) { // ID 중복 확인 (Read - one)
            model.addAttribute("errorMessage", "이미 존재하는 ID입니다.");
            System.out.println("아이디 중복으로 다시 회원가입 화면으로 돌아옴: id=" + member.getId());
            return "joinForm"; // 에러와 함께 폼으로 돌아감
        }
        memberService.save(member); // 회원 정보 저장 (Create)
        return "joinResult"; // "joinResult.jsp" 뷰 반환 (성공 페이지)
    }

    // --- Update ---
    // showEditForm 메서드: "/member/editForm" 경로에 대한 GET 요청 처리
    // 목적: 로그인한 사용자에게 비밀번호 수정 폼을 보여줌
    @GetMapping("/editForm")
    public String showEditForm(HttpSession session) {
        System.out.println("회원정보 수정 컨트롤러 진입");
        return "editForm"; // "editForm.jsp" 뷰 반환
    }

    // updatePassword 메서드: "/member/updatePassword" 경로에 대한 POST 요청 처리
    // 목적: 사용자가 입력한 새 비밀번호로 회원 비밀번호 업데이트
   @PostMapping("/updatePassword")
    public String updatePassword(HttpServletRequest request) {
    	String id = request.getParameter("id");             // 사용자 ID
        String pw = request.getParameter("pw");             // 새 비밀번호
        String confirmPassword = request.getParameter("confirmPassword"); // 비밀번호 확인 (현재 사용되지 않음)

        System.out.println("[Controller] 비밀번호 수정 요청 도착");
        System.out.println("[Controller] 파라미터 id = " + id + ", pw = " + pw);

        memberService.updatePassword(id, pw); // 비밀번호 업데이트 (Update)
        System.out.println("[Controller] 비밀번호 수정 후 editForm으로 리다이렉트");
        return "redirect:/"; // 메인 페이지로 리다이렉트
    }

    // deactivateUser 메서드: "/member/deactivateUser" 경로에 대한 POST 요청 처리
    // 목적: 로그인한 회원의 계정 상태를 'INACTIVE'로 변경하고, 세션을 무효화하여 로그아웃 처리 (논리적 삭제)
    @PostMapping("/deactivateUser")
    public String deactivateUser(HttpServletRequest request) {
    	System.out.println("회원 탈퇴 컨트롤러 진입");

    	Member member = (Member) request.getSession().getAttribute("loginMember"); // 세션에서 로그인 Member 객체 가져옴 (Read - one)
    	String id = member.getId(); // 로그인된 사용자의 ID

        System.out.println("탈퇴 요청 ID: " + id);
        memberService.deactivate(id);       // 회원 비활성화 (Update - status)
        System.out.println("상태 변경 완료, 세션 끊기기 직전.");
        request.getSession().invalidate();   // 세션 무효화 (로그아웃)
        System.out.println("세션 끊었음. 사용자는 이후 메인 페이지로 돌아갑니다.");
    	return "redirect:/"; // 메인 페이지로 리다이렉트
    }
    
    // --- Read (One/My Page) ---
    // showMyPage 메서드: "/member/mypage" 경로에 대한 GET 요청 처리
    // 목적: 로그인한 사용자에게 사용자가 작성한 모든 리뷰 조회 뷰
    @GetMapping("/mypage")
    public String myPage(Model model, HttpSession session) {
    	System.out.println("마이페이지의 사용자 모든 리뷰 조회하기");
    	Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/login";
        }

        String memberId = loginMember.getId();

        // 1. 내가 쓴 리뷰 목록 가져오기
        List<UserReview> myReviews = userReviewService.getMyReviews(memberId);

        // 2. 영화 정보 가져와서 Map에 저장
        Map<Long, movie> movieMap = new HashMap<>();
        for (UserReview r : myReviews) {
            Long movieId = r.getMovieId();
            if (!movieMap.containsKey(movieId)) {
                movie m = movieRepository.findTitleAndPosterById(movieId);
                if (m != null) {
                    movieMap.put(movieId, m);
                }
            }
        }

        // 3. 모델에 담기
        model.addAttribute("myReviews", myReviews);
        model.addAttribute("movieMap", movieMap);
        return "mypage";
    }
}