package com.springmvc.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

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
}