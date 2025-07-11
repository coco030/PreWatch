package com.springmvc.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.springmvc.domain.Member;
import com.springmvc.service.MemberService;

@Controller
public class LoginController {

    @Autowired
    private MemberService memberService;

    // 로그인 폼 보여주기
    @GetMapping("/login")
    public String showLoginForm() {
        System.out.println("[LoginController] 로그인 폼 요청됨");
        return "login";
    }

    // 로그인 처리
    @PostMapping("/login")
    public String processLogin(@RequestParam String id, @RequestParam String password, HttpSession session, RedirectAttributes rttr) {
        System.out.println("[LoginController] 로그인 시도: id=" + id);
        Member loginMember = memberService.login(id, password);

        if (loginMember != null) {
            // 성공 시
            System.out.println("[LoginController] 로그인 성공, 세션 저장 완료");
            session.setAttribute("loginMember", loginMember);
            return "redirect:/";
        } else {
            // 실패 시
            System.out.println("[LoginController] 로그인 실패");
            rttr.addFlashAttribute("errorMessage", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "redirect:/login";
        }
    }

    // 로그아웃 처리
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        System.out.println("[LoginController] 로그아웃 처리됨");
        session.invalidate();
        return "redirect:/";
    }
}