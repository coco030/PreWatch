package com.springmvc.controller;

//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LoginController {
	
//	public static Logger logger = LoggerFactory.getLogger(LoginController.class);
		@GetMapping("/login")
		public String login() {
			System.out.println("LoginController 실행됨");
			return "login";
		}
		@GetMapping("/loginfailed")
		public String loginerror(Model model) {
			model.addAttribute("error","true");
			System.out.println("LoginController failed실행됨");
			return "login";
		}
		@GetMapping("/logout")
		public String logout(Model model) {
			System.out.println("logout 실행됨");
			return "login"; 
		}
}
