package com.springmvc.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.springmvc.domain.movie;
import com.springmvc.repository.ActorRepository;
import com.springmvc.service.TmdbApiService;
import com.springmvc.service.movieService;

@Controller
public class ActorController {
	
	@Autowired
	private movieService movieService;

    @Autowired
    private ActorRepository actorRepository;

    @Autowired
    private TmdbApiService tmdbApiService;
    
 // ✅ 배우 상세 페이지
    @GetMapping("/actors/{id}")
    public String actorDetail(@PathVariable Long id, Model model) {
        Map<String, Object> actor = actorRepository.findActorDetail(id);
        model.addAttribute("actor", actor);
        return "movie/actor_detail"; //
    }

    // ✅ 감독 상세 페이지 (같은 뷰)
    @GetMapping("/directors/{id}")
    public String directorDetail(@PathVariable Long id, Model model) {
        Map<String, Object> director = actorRepository.findActorDetail(id);
        model.addAttribute("actor", director);
        return "movie/actor_detail"; // ✅ 동일한 JSP
    }
    

}