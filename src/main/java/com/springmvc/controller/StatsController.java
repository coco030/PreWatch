package com.springmvc.controller;

import com.springmvc.domain.GlobalStatsDTO;
import com.springmvc.service.StatisticsService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/stats")
public class StatsController {

    @Autowired
    private StatisticsService statisticsService;

    @GetMapping("/global")
    public String showGlobalStats(Model model) {
        GlobalStatsDTO globalStats = statisticsService.getGlobalStats();
        model.addAttribute("globalStats", globalStats);
        return "stats/globalStats";  // → /WEB-INF/views/stats/globalStats.jsp
    }
}
