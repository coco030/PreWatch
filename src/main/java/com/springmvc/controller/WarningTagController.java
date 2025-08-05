package com.springmvc.controller;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.springmvc.domain.WarningTag;
import com.springmvc.domain.movie;
import com.springmvc.repository.movieRepository;
import com.springmvc.service.WarningTagService;
import com.springmvc.service.movieService;

@Controller
@RequestMapping("/admin/warnings")
public class WarningTagController {

    @Autowired
    private movieRepository movieRepository;

    @Autowired
    private WarningTagService warningTagService;

    @Autowired
    private movieService movieService;

//특정 영화의 주의 요소 관리 페이지(get)
    @GetMapping("/{movieId}")
    public String showWarningTagForm(@PathVariable("movieId") long movieId, Model model) {
        
        List<WarningTag> allTags = warningTagService.getAllWarningTags();
        Map<String, List<WarningTag>> allTagsGrouped = allTags.stream()
                .collect(Collectors.groupingBy(WarningTag::getCategory, LinkedHashMap::new, Collectors.toList()));
        model.addAttribute("allTagsGrouped", allTagsGrouped);

        List<Long> selectedTagIds = warningTagService.getWarningTagIdsByMovieId(movieId);
        model.addAttribute("selectedTagIds", selectedTagIds);

        movie movie = movieService.findById(movieId);
        model.addAttribute("movie", movie);
        model.addAttribute("movieId", movieId);

        return "admin/warningTagForm";
    }

 //특정 영화의 주의 요소를 저장하는 메소드 (POST)
    @PostMapping("/{movieId}")
    public String saveWarningTags(@PathVariable("movieId") long movieId,
                                  @RequestParam(value = "tagIds", required = false) List<Long> tagIds) {

    	 if (tagIds == null) {
 	        tagIds = new java.util.ArrayList<>();
 	    }
    	
        warningTagService.updateMovieWarningTags(movieId, tagIds);
        return "redirect:/admin/warnings/" + movieId + "?update=success";
    }

//모든 영화의 주의 요소를 한 페이지에서 관리하는 페이지 (GET)
    @GetMapping("/all")
    public String showAllMovieWarningsForm(Model model) {
    
        List<movie> allMovies = movieRepository.findAll();
        model.addAttribute("allMovies", allMovies);

  
        List<WarningTag> allTags = warningTagService.getAllWarningTags();
        Map<String, List<WarningTag>> allTagsGrouped = allTags.stream()
                .collect(Collectors.groupingBy(WarningTag::getCategory, LinkedHashMap::new, Collectors.toList()));
        model.addAttribute("allTagsGrouped", allTagsGrouped);


        Map<Long, List<Long>> movieToSelectedTagsMap = new HashMap<>();
        for (movie movie : allMovies) {
            List<Long> selectedIds = warningTagService.getWarningTagIdsByMovieId(movie.getId());
            movieToSelectedTagsMap.put(movie.getId(), selectedIds);
        }
        model.addAttribute("movieToSelectedTagsMap", movieToSelectedTagsMap);

        return "admin/warningTagFormAll";
    }
    
 // 전체 관리 페이지에서 변경된 내용을 저장하는 메소드 (POST)
    @PostMapping("/all")
    @Transactional 
    public String saveAllMovieWarnings(HttpServletRequest request) {
     
        List<movie> allMovies = movieRepository.findAll();

      
        for (movie movie : allMovies) {
           
            String paramName = "tags_" + movie.getId();
            String[] tagIdStrings = request.getParameterValues(paramName);
            java.util.List<Long> tagIds = new java.util.ArrayList<>();
            if (tagIdStrings != null) {
                for (String idStr : tagIdStrings) {
                    tagIds.add(Long.parseLong(idStr));
                }
            }

            warningTagService.updateMovieWarningTags(movie.getId(), tagIds);
        }
        return "redirect:/admin/warnings/all?update=success";
    }
}