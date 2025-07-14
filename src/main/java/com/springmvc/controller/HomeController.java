package com.springmvc.controller;

import com.springmvc.service.movieService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {
	private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    @Autowired
    private movieService movieService; 

    public HomeController() {
        System.out.println("public HomeController 객체생성");
    }

    @GetMapping("/")
    public String home(Model model) { // Model을 매개변수로 추가
        logger.info("루트 경로 '/' 요청이 감지되었습니다. 홈페이지를 로드합니다.");
        // 모든 영화를 가져와서 'movies'라는 이름으로 모델에 추가합니다.
        // 여기서는 간단히 모든 영화를 가져오지만, 추후 '최신 영화' 등 특정 조건으로 필터링 가능합니다.
        model.addAttribute("movies", movieService.findAll());
        logger.debug("movieService.findAll() 호출 완료. 홈페이지에 영화 목록을 표시합니다.");
        return "home"; 
    }
}
