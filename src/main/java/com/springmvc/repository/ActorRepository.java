package com.springmvc.repository;

import java.sql.PreparedStatement;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

@Repository
public class ActorRepository {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 배우 이름(혹은 tmdb_id)로 이미 존재하는지 확인
    public Long findByNameOrInsert(String name, String profileImageUrl, Integer tmdbId) {
        // 1. 먼저 동일 이름 배우가 있는지 확인
        String selectSql = "SELECT id FROM actors WHERE name = ? LIMIT 1";
        List<Long> ids = jdbcTemplate.query(selectSql, (rs, rowNum) -> rs.getLong("id"), name);
        if (!ids.isEmpty()) {
            return ids.get(0);
        }

        // 2. 없으면 새로 추가 (안정적 방식)
        String insertSql = "INSERT INTO actors (name, profile_image_url, tmdb_id) VALUES (?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        int rowsAffected = jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(insertSql, new String[]{"id"});
            ps.setString(1, name);
            ps.setString(2, profileImageUrl);
            if (tmdbId != null) ps.setInt(3, tmdbId);
            else ps.setNull(3, java.sql.Types.INTEGER);
            return ps;
        }, keyHolder);

        if (rowsAffected <= 0 || keyHolder.getKey() == null) {
            System.out.println("[ERROR] 배우 INSERT 실패 또는 키 회수 실패: name=" + name);
            return null;
        }

        return keyHolder.getKey().longValue();
    }



    // 영화-배우(감독) 연결 저장
    public void saveMovieActorMapping(Long movieId, Long actorId, String roleName, String roleType, int displayOrder) {
        if (movieId == null || actorId == null) {
            System.out.println("[WARN] movieId 또는 actorId null: movieId=" + movieId + ", actorId=" + actorId);
            return;
        }
        String sql = "INSERT INTO movie_actors (movie_id, actor_id, role_name, role_type, display_order) VALUES (?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, movieId, actorId, roleName, roleType, displayOrder);

    }

    // 영화 id로 출연진 조회
    public List<Map<String, Object>> findCastAndCrewByMovieId(Long movieId) {
        String sql =
            "SELECT a.id, a.name, a.profile_image_url, m.role_name, m.role_type, m.display_order " +
            "FROM movie_actors m JOIN actors a ON m.actor_id = a.id WHERE m.movie_id = ? ORDER BY m.display_order ASC";
        return jdbcTemplate.queryForList(sql, movieId);
    }

    // 배우/감독 id로 상세 정보
    public Map<String, Object> findActorDetail(Long actorId) {
        String sql = "SELECT * FROM actors WHERE id = ?";
        return jdbcTemplate.queryForMap(sql, actorId);
    }
    
    // 배우 상세 정보
    public void updateActorDetails(Long actorId, Map<String, Object> details) {
    	String sql = "UPDATE actors SET birthday = ?, deathday = ?, age = ?, place_of_birth = ?, biography = ?, gender = ?, known_for_department = ? WHERE id = ?";
        jdbcTemplate.update(sql,
            details.get("birthday"),
            details.get("deathday"),
            details.get("age"),
            details.get("place_of_birth"),
            details.get("biography"),
            details.get("gender"),
            details.get("known_for_department"),
            actorId
        );
    }




}
