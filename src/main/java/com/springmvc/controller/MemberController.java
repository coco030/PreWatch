package com.springmvc.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.springmvc.domain.Member;
import com.springmvc.service.MemberService;

@Controller
public class MemberController {

    @Autowired
    private MemberService memberService;
    
    // 메인 페이지 보여주기
    @GetMapping("/")
    public String showHomePage() {
    	System.out.println("Membercontroller 메인 보여주기");
        return "home"; // home.jsp
    }
    
    // 회원가입 폼 보여주기
    @GetMapping("/join")
    public String showJoinForm(Model model) {	
    	System.out.println("Membercontroller 회원가입 폼 보여주기");
        model.addAttribute("member", new Member()); 
        return "joinForm"; // joinForm.jsp
    }

    // 회원가입 처리
    @PostMapping("/join")
    
    public String processJoin(@ModelAttribute Member member, Model model) {
    	System.out.println("[MemberController] 회원가입 처리 시도: id=" + member.getId());
        if (memberService.existsById(member.getId())) {
            model.addAttribute("errorMessage", "이미 존재하는 ID입니다.");
            System.out.println("아이디 중복으로 다시 회원가입 화면으로 돌아옴: id=" + member.getId());
            return "joinForm";
        }
        memberService.save(member);
        return "joinResult"; // joinResult.jsp
    }
    // 비밀번호 수정 폼: GET /member/editForm
    @GetMapping("/editForm") // RequestMapping에서 GetMapping으로.
    public String showEditForm(HttpSession session) {
        System.out.println("회원정보 수정 컨트롤러 진입");
        return "editForm";
    }
    //비밀번호 수정 처리: POST /member/editPassword였지만 폼으로 전송되지 않았으므로
   // POST /member/updatePassword 주소를 처리하도록 수정
    @PostMapping("/updatePassword") 
    public String editPassword(HttpServletRequest request) {	
    	String id = request.getParameter("id");
        String pw = request.getParameter("pw");
        String confirmPassword = request.getParameter("confirmPassword");

        System.out.println("[Controller] 비밀번호 수정 요청 도착");
        System.out.println("[Controller] 파라미터 id = " + id + ", pw = " + pw);

        memberService.updatePassword(id, pw);
        System.out.println("[Controller] 비밀번호 수정 후 editForm으로 리다이렉트");
        // 성공 후 어디로 갈지? 보통 마이페이지나 메인으로 가지만 여기선 수정폼으로 되돌아가도록 함.
        return "redirect:/"; // 메인 페이지로 이동
    }
    
    //회원탈퇴. (상태만 'INACTIVE' 로 두어서 리뷰나 별점을 남겨둡니다. 그래서 실제로는 update 기능)
    @PostMapping("/deactivateUser") 
    public String deactivateUser(HttpServletRequest request) {
    	System.out.println("회원 탈퇴 컨트롤러 진입");
    	
    	Member member = (Member) request.getSession().getAttribute("loginMember");
    	String id = member.getId();
        System.out.println("탈퇴 요청 ID: " + id);
        memberService.deactivate(id);       // 여기서 상태 변경
        System.out.println("상태 변경 완료, 세션 끊기기 직전.");
        request.getSession().invalidate();   // 세션 끊기
        System.out.println("세션 끊었음. 사용자는 이후 메인 페이지로 돌아갑니다.");
    	return "redirect:/"; // 탈퇴 후 메인 페이지로 이동
    	
    }
    //마이페이지. 나의 영화 리뷰나 별점 목록 (볼 수만 있고 이 페이지에서 수정삭제 불가)
    @GetMapping("/mypage")
    public String showMyPage() {
    	System.out.println("마이페이지로 이동");
        return "mypage";
    }
}