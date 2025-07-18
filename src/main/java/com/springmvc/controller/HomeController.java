/*
    파일명: HomeController.java
    설명:
        이 class는 home.jsp 요청을 처리하하기 위한 컨트롤러입니다.

    목적:
        사용자가 웹사이트에 처음 접속했을 때 home.jsp(http://localhost:8080/PreWatch/)로 이동하게 하기 위해서.
     */

package com.springmvc.controller;

import com.springmvc.service.movieService; 

import org.slf4j.Logger;         
import org.slf4j.LoggerFactory;  
import org.springframework.beans.factory.annotation.Autowired; 
import org.springframework.stereotype.Controller;            
import org.springframework.ui.Model;                         
import org.springframework.web.bind.annotation.GetMapping;   



@Controller 
public class HomeController {
	private static final Logger logger = LoggerFactory.getLogger(HomeController.class); 
	//Logger 객체 초기화

    @Autowired
    private movieService movieService; 
    // 메인 페이지에 표시할 영화 목록을 가져오기 위해 movieService를 주입.

    public HomeController() {
        System.out.println("public HomeController 객체생성"); 
        // 디버깅용 로그
    }

    @GetMapping("/") 
    public String home(Model model) { 
    	// Model 객체를 주입받습니다. 뷰에 데이터를 전달하는 데 사용.
        logger.info("루트 경로 '/' 요청이 감지되었습니다. 홈페이지를 불러옵니다.");
        model.addAttribute("movies", movieService.findAll());
        // `home.jsp`에 포함된 `main.jsp`에서 화면에 표시하기 위해 주입받은 movieService를 통해 모든 영화 목록을 조회하여 'movies'라는 이름으로 모델에 추가.
        logger.debug("movieService.findAll() 호출 완료. 홈페이지에 영화 목록을 표시합니다.");
        return "home"; 
        // "home.jsp 주소 반환.
    }
}