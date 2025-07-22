package com.springmvc.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

// UserCartRepositoryImpl 클래스: UserCartRepository 인터페이스를 구현하는 클래스입니다.
// 목적: JdbcTemplate을 사용하여 'user_carts' 테이블에 대한 실제 데이터베이스 작업을 수행합니다.
// 관계: (클래스 다이어그램: UserCartRepositoryImpl -> UserCartRepository (구현 관계))
@Repository // Spring이 이 클래스를 데이터 접근 계층의 빈으로 등록하도록 지시합니다.
public class userCartRepositoryImpl implements userCartRepository {

    private static final Logger logger = LoggerFactory.getLogger(userCartRepositoryImpl.class); // 로깅을 위한 Logger 인스턴스

    private final JdbcTemplate jdbcTemplate; // 데이터베이스 작업을 수행할 JdbcTemplate 객체

    // 생성자를 통한 DataSource 주입: JdbcTemplate 초기화.
    @Autowired
    public userCartRepositoryImpl(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        logger.info("UserCartRepositoryImpl 초기화: DataSource 주입 완료.");
    }

    // addMovieToCart 메서드 구현: 특정 회원의 찜 목록에 영화를 추가.
    // 목적: 사용자가 영화를 찜할 때 호출.
    @Override
    public void addMovieToCart(String memberId, Long movieId) {
        logger.debug("찜 목록에 영화 추가 시도: memberId={}, movieId={}", memberId, movieId);
        String sql = "INSERT INTO user_carts (member_id, movie_id) VALUES (?, ?)";
        try {
            jdbcTemplate.update(sql, memberId, movieId);
            logger.info("영화 ID {}가 회원 {}의 찜 목록에 추가되었습니다.", movieId, memberId);
        } catch (Exception e) {
            // UNIQUE 제약 조건 위반 (이미 찜한 경우) 등 예외 처리
            logger.error("찜 목록에 영화 추가 실패 (memberId={}, movieId={}): {}", memberId, movieId, e.getMessage());
            throw new RuntimeException("찜 목록 추가 실패", e);
        }
    }

    // removeMovieFromCart 메서드 구현: 특정 회원의 찜 목록에서 영화를 제거.
    // 목적: 사용자가 찜을 취소할 때 호출.
    @Override
    public void removeMovieFromCart(String memberId, Long movieId) {
        logger.debug("찜 목록에서 영화 제거 시도: memberId={}, movieId={}", memberId, movieId);
        String sql = "DELETE FROM user_carts WHERE member_id = ? AND movie_id = ?";
        int deletedRows = jdbcTemplate.update(sql, memberId, movieId);
        if (deletedRows > 0) {
            logger.info("영화 ID {}가 회원 {}의 찜 목록에서 제거되었습니다.", movieId, memberId);
        } else {
            logger.warn("찜 목록에서 영화 제거 실패: 회원 {}의 찜 목록에 영화 ID {}가 없거나 이미 제거됨.", memberId, movieId);
        }
    }

    // isMovieInCart 메서드 구현: 특정 영화가 특정 회원의 찜 목록에 있는지 확인.
    // 목적: JSP에서 하트 아이콘의 상태(빈 하트/꽉 찬 하트)를 결정할 때 사용.
    @Override
    public boolean isMovieInCart(String memberId, Long movieId) {
        logger.debug("영화 ID {}가 회원 {}의 찜 목록에 있는지 확인 시도.", movieId, memberId);
        String sql = "SELECT COUNT(*) FROM user_carts WHERE member_id = ? AND movie_id = ?";
        try {
            Integer count = jdbcTemplate.queryForObject(sql, Integer.class, memberId, movieId);
            boolean exists = (count != null && count > 0);
            logger.debug("영화 ID {}는 회원 {}의 찜 목록에 {}합니다.", movieId, memberId, exists ? "존재" : "존재하지 않");
            return exists;
        } catch (EmptyResultDataAccessException e) {
            // count(*) 쿼리는 EmptyResultDataAccessException을 발생시키지 않으므로 사실상 불필요.
            return false;
        } catch (Exception e) {
            logger.error("찜 목록 확인 중 오류 발생 (memberId={}, movieId={}): {}", memberId, movieId, e.getMessage());
            throw new RuntimeException("찜 목록 확인 실패", e);
        }
    }

    // findMovieIdsInCartByMemberId 메서드 구현: 특정 회원이 찜한 모든 영화의 ID 목록 조회.
    // 목적: 마이페이지 등에서 사용자가 찜한 영화들의 ID를 가져와 상세 정보를 조회할 때 사용.
    @Override
    public List<Long> findMovieIdsInCartByMemberId(String memberId) {
        logger.debug("회원 {}이 찜한 영화 ID 목록 조회 시도.", memberId);
        String sql = "SELECT movie_id FROM user_carts WHERE member_id = ?";
        List<Long> movieIds = jdbcTemplate.queryForList(sql, Long.class, memberId);
        logger.info("회원 {}이 찜한 영화 {}개 목록 가져옴.", memberId, movieIds.size());
        return movieIds;
    }
}