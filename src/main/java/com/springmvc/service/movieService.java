package com.springmvc.service;

import com.springmvc.domain.movie;
import com.springmvc.repository.movieRepository;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

@Service
public class movieService {

    private static final Logger logger = LoggerFactory.getLogger(movieService.class);

    private final movieRepository movieRepository;

    public movieService(movieRepository movieRepository) {
        this.movieRepository = movieRepository;
    }

    public List<movie> findAll() {
        logger.debug("movieService.findAll() 호출.");
        List<movie> movies = movieRepository.findAll();
        logger.debug("DB에서 {}개의 영화 목록을 가져왔습니다.", movies.size());
        return movies;
    }

    public movie findById(Long id) {
        logger.debug("movieService.findById({}) 호출.", id);
        movie movie = movieRepository.findById(id);
        if (movie != null) {
            logger.debug("영화 ID {} 찾음: {}", id, movie.getTitle());
        } else {
            logger.debug("영화 ID {} 찾을 수 없음.", id);
        }
        return movie;
    }

    public void save(movie movie) {
        logger.debug("movieService.save() 호출: 영화 제목 = {}", movie.getTitle());
        movieRepository.save(movie);
        logger.info("영화 '{}'가 DB에 저장되었습니다.", movie.getTitle());
    }

    public void update(movie movie) {
        logger.debug("movieService.update() 호출: 영화 ID = {}", movie.getId());
        movieRepository.update(movie);
        logger.info("영화 ID {}가 업데이트되었습니다.", movie.getId());
    }

    public void delete(Long id) {
        logger.debug("movieService.delete() 호출: 영화 ID = {}", id);
        movieRepository.delete(id);
        logger.info("영화 ID {}가 삭제되었습니다.", id);
    }
}