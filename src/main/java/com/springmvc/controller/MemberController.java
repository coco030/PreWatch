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
    
    
    
    //editForm 이동하게 함. get
    @RequestMapping(value = "/editForm", method = RequestMethod.GET)
    public String showEditForm(HttpSession session) {
        Object loginMember = session.getAttribute("loginMember");
        System.out.println("Membercontroller 비밀번호 바꾸는 페이지 보여주기");
        return "editForm";
    }
    
    //비밀번호 수정 정보 보내서 post
    @RequestMapping(value = "/editPassword", method = RequestMethod.POST)
    public String editPassword(HttpServletRequest request) {
        String id = request.getParameter("id");
        String pw = request.getParameter("pw");

        System.out.println("[Controller] 비밀번호 수정 요청 도착");
        System.out.println("[Controller] 파라미터 id = " + id + ", pw = " + pw);

        memberService.updatePassword(id, pw);

        System.out.println("[Controller] 비밀번호 수정 후 editForm으로 리다이렉트");
        return "redirect:/member/editForm";
    }
    
    
    
}