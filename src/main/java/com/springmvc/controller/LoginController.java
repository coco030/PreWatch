package com.springmvc.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.springmvc.domain.Member; // Member 클래스 임포트 확인
import com.springmvc.service.MemberService;

@Controller
@RequestMapping("/auth") 
public class LoginController {

    @Autowired
    private MemberService memberService;

    // 로그인 폼 보여주기
    @GetMapping("/login")
    public String showLoginForm() {
        System.out.println("[LoginController] 로그인 폼 요청됨");
        return "login"; // login.jsp
    }

    // 로그인 처리
    @PostMapping("/login")
    public String processLogin(@RequestParam String id, @RequestParam String password, HttpSession session, RedirectAttributes rttr) {
        System.out.println("[LoginController] 로그인 시도: id=" + id);
        
        Member loginMember = memberService.login(id, password);

        if (loginMember != null) {
            // 로그인 성공
            System.out.println("[LoginController] 로그인 성공, 세션 저장 완료");
            session.setAttribute("loginMember", loginMember);
            
            // ⭐ Member 객체의 role 필드를 가져와 세션에 "userRole" 이름으로 저장
            // Member 클래스에 getRole() 메서드가 반드시 있어야 합니다.
            String userRole = loginMember.getRole();
            if (userRole == null || userRole.isEmpty()) {
                // role이 설정되지 않았다면 기본적으로 "MEMBER"로 처리 (기본 역할 지정)
                userRole = "MEMBER"; 
            }
            session.setAttribute("userRole", userRole);
            System.out.println("[LoginController] 세션에 userRole: " + userRole + " 저장됨.");

            return "redirect:/"; // 메인 페이지로 리다이렉트
        } else {
            // 로그인 실패
            System.out.println("[LoginController] 로그인 실패");
            rttr.addFlashAttribute("errorMessage", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "redirect:/login"; // 로그인 폼으로 다시 리다이렉트
        }
    }

    // 로그아웃 처리
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        System.out.println("[LoginController] 로그아웃 처리됨");
        session.invalidate(); // 세션 무효화
        System.out.println("[LoginController] 세션 무효화 완료.");
        return "redirect:/"; // 메인 페이지로 리다이렉트
    }
}