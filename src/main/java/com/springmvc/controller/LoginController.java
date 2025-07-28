/*
    파일명: LoginController.java
    설명:
        이 class는 로그인 및 로그아웃과 관련된 HTTP 요청을 처리하는 컨트롤러입니다.

    목적:
        사용자가 로그인 및 로그아웃을 하기 위함.

*/


package com.springmvc.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.springmvc.domain.Member;     // Member 도메인 클래스 임포트
import com.springmvc.service.MemberService; // MemberService 인터페이스 임포트

@Controller
@RequestMapping("/auth")
public class LoginController {

    @Autowired
    private MemberService memberService; // 로그인 비즈니스 로직(사용자 인증)을 MemberService에 가져가기 위해 MemberService를 주입.


    // --- Read (Login Form) ---
    @GetMapping("/login")
    public String showLoginForm() {
        System.out.println("[LoginController] 로그인 폼 요청됨");
        return "login"; // "login.jsp" 뷰 주소를 반환.
    }

    // --- Create (Session - Login Process) ---
    @PostMapping("/login")
    public String processLogin(@RequestParam String id,             // 요청 파라미터 'id'를 String 타입으로 받음.
                               @RequestParam String password,       // 요청 파라미터 'password'를 String 타입으로 받음.
                               HttpSession session,                  // HTTP 세션 객체를 주입받습니다. 로그인 정보를 저장하는 데 사용하기 위해.
                               RedirectAttributes rttr) {           // 일회성으로 쓰기 위해 RedirectAttributes 사용.
        System.out.println("[LoginController] 로그인 시도: id=" + id);

        // MemberService를 통해 로그인 비즈니스 로직을 호출합니다. (Read - one)
        // login 메서드는 ID와 비밀번호가 일치하고 ACTIVE 상태인 Member 객체를 반환하거나, 실패 시 null을 반환.
        Member loginMember = memberService.login(id, password);

        if (loginMember != null) {
            // 로그인 성공
            System.out.println("[LoginController] 로그인 성공, 세션 저장 완료");
            session.setAttribute("loginMember", loginMember); // 로그인 성공한 Member 객체를 세션에 "loginMember"라는 이름으로 저장.
                                                            // JSP에서 `sessionScope.loginMember`로 접근 가능합니다.

            String userRole = loginMember.getRole(); // Member 객체의 role 필드를 가져와 세션에 "userRole" 이름으로 저장
            // userRole은 관리자와,회원,비회원을 나누기 위한 변수.

            if (userRole == null || userRole.isEmpty()) {
                // role이 설정되지 않았다면 기본적으로 "MEMBER"로 처리.
                userRole = "MEMBER";
            }
            session.setAttribute("userRole", userRole); // 사용자의 역할(예: "ADMIN", "MEMBER")을 세션에 저장.
            System.out.println("[LoginController] 세션에 userRole: " + userRole + " 저장됨.");

            return "redirect:/auth/login-success";
            // 로그인 성공 후 루트 경로("/home"(홈페이지))로 리다이렉트.

        } else {
            // 로그인 실패 (ID/비밀번호 불일치 또는 비활성화 계정)
            System.out.println("[LoginController] 로그인 실패");
            rttr.addFlashAttribute("errorMessage", "아이디 또는 비밀번호가 올바르지 않습니다.");
            // 위의 RedirectAttributes와 유사.
            // 리다이렉트 후에도 한 번만 사용할 수 있는 데이터를 모델에 추가 후, 삭제.
            return "redirect:/login";
            // 로그인 폼으로 다시 리다이렉트합니다.
        }
    }

    // --- Delete (Session - Logout Process) ---
    @GetMapping("/logout") // "/auth/logout" 경로에 대한 GET 요청을 처리
    public String logout(HttpSession session) {
        System.out.println("[LoginController] 로그아웃 처리됨");
        session.invalidate(); // 현재 세션을 완전히 지움. 세션에 저장된 모든 속성(loginMember, userRole 등)이 제거.
        System.out.println("[LoginController] 세션 무효화 완료.");
        return "redirect:/"; // 로그아웃 후 루트 경로("/home"(홈페이지))로 리다이렉트.
    }
    
    // 모달창에서 빠져나가 로그인하기 위한 컨트롤러
    @GetMapping("/login-success")
    public String loginSuccess() {
        return "login-success"; // JSP 파일명과 일치
    }
}