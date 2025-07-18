package com.springmvc.service;

import com.springmvc.domain.movie; 
import com.springmvc.repository.movieRepository; 
import org.springframework.stereotype.Service; 
import org.slf4j.Logger; 
import org.slf4j.LoggerFactory; 

import java.util.List; 

// movieService 클래스: 영화(movie) 관련 비즈니스 로직 구현.
// 목적: Controller와 Repository 사이에서 비즈니스 규칙 적용 및 트랜잭션 관리.
@Service // Spring 빈으로 등록
public class movieService {

    private static final Logger logger = LoggerFactory.getLogger(movieService.class); // Logger 객체 초기화

    private final movieRepository movieRepository; // movieRepository 주입 필드

    // 생성자를 통한 movieRepository 주입.
    // 목적: 불변성 확보 및 테스트 용이성 증가.
    public movieService(movieRepository movieRepository) {
        this.movieRepository = movieRepository;
    }

    // findAll 메서드: 모든 영화 목록 조회.
    // 목적: Controller에서 호출, 실제 데이터 조회는 Repository에 위임.
    public List<movie> findAll() {
        logger.debug("movieService.findAll() 호출.");
        List<movie> movies = movieRepository.findAll();
        logger.debug("DB에서 {}개의 영화 목록을 가져왔습니다.", movies.size());
        return movies;
    }

    // findById 메서드: 특정 ID 영화 정보 조회.
    // 목적: Controller에서 영화 상세 페이지 요청 시 호출.
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

    /**
     * findByApiId 메서드: API ID (imdbID)를 사용하여 DB에서 영화 조회.
     * 목적: 외부 API 검색 결과에 로컬 평점/잔혹도 덮어씌울 때 사용.
     * apiId OMDb 등 외부 API의 고유 ID.
     * @return 해당 apiId를 가진 movie 객체, 없으면 null.
     */
    public movie findByApiId(String apiId) {
        logger.debug("movieService.findByApiId({}) 호출.", apiId);
        movie movie = movieRepository.findByApiId(apiId);
        if (movie != null) {
            logger.debug("API ID {}에 해당하는 영화 찾음: {}", apiId, movie.getTitle());
        } else {
            logger.debug("API ID {}에 해당하는 영화 찾을 수 없음.", apiId);
        }
        return movie;
    }

    // save 메서드: 새 영화 정보 저장.
    // 목적: Controller에서 영화 등록 요청 시 호출.
    public void save(movie movie) {
        logger.debug("movieService.save() 호출: 영화 제목 = {}", movie.getTitle());
        movieRepository.save(movie);
        logger.info("영화 '{}'가 DB에 저장되었습니다.", movie.getTitle());
    }

    // update 메서드: 기존 영화 정보 업데이트.
    // 목적: Controller에서 영화 수정 요청 시 호출.
    public void update(movie movie) {
        logger.debug("movieService.update() 호출: 영화 ID = {}", movie.getId());
        movieRepository.update(movie);
        logger.info("영화 ID {}가 업데이트되었습니다.", movie.getId());
    }

    // delete 메서드: 특정 영화 정보 삭제.
    // 목적: Controller에서 영화 삭제 요청 시 호출.
    public void delete(Long id) {
        logger.debug("movieService.delete() 호출: 영화 ID = {}", id);
        movieRepository.delete(id);
        logger.info("영화 ID {}가 삭제되었습니다.", id);
    }
}