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
        System.out.println("[LOG] findByNameOrInsert 호출: name=" + name + ", tmdb_id=" + tmdbId);

        // 1. tmdb_id가 있으면 그걸로 먼저 중복 확인 (가장 정확)
        if (tmdbId != null) {
            String tmdbSql = "SELECT id FROM actors WHERE tmdb_id = ? LIMIT 1";
            List<Long> tmdbMatches = jdbcTemplate.query(tmdbSql, (rs, rowNum) -> rs.getLong("id"), tmdbId);
            if (!tmdbMatches.isEmpty()) {
                System.out.println("[LOG] TMDB ID 중복 배우 존재: id=" + tmdbMatches.get(0));
                return tmdbMatches.get(0);
            }
        }

        // 2. tmdb_id 없거나 조회 안됐으면 이름 기반으로 검사 (보조 수단)
        String nameSql = "SELECT id FROM actors WHERE name = ? LIMIT 1";
        List<Long> nameMatches = jdbcTemplate.query(nameSql, (rs, rowNum) -> rs.getLong("id"), name);
        if (!nameMatches.isEmpty()) {
            System.out.println("[LOG] 이름 중복 배우 존재: id=" + nameMatches.get(0));
            return nameMatches.get(0);
        }

        // 3. 둘 다 없으면 새로 INSERT
        System.out.println("[LOG] 신규 배우 INSERT 시도: name=" + name + ", tmdb_id=" + tmdbId);
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
            System.out.println("[ERROR] 배우 INSERT 실패 또는 키 회수 실패: name=" + name + ", tmdb_id=" + tmdbId);
            return null;
        }

        Long newId = keyHolder.getKey().longValue();
        System.out.println("[SUCCESS] 배우 INSERT 성공: id=" + newId);
        return newId;
    }

    // 영화-배우(감독) 연결 저장
    public void saveMovieActorMapping(Long movieId, Long actorId, String roleName, String roleType, int displayOrder) {
        if (movieId == null || actorId == null) {
            System.out.println("[WARN] movieId 또는 actorId null: movieId=" + movieId + ", actorId=" + actorId);
            return;
        }
        System.out.println("[LOG] 영화-배우 매핑 저장: movieId=" + movieId + ", actorId=" + actorId + ", roleType=" + roleType + ", order=" + displayOrder);
        String sql = "INSERT INTO movie_actors (movie_id, actor_id, role_name, role_type, display_order) VALUES (?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, movieId, actorId, roleName, roleType, displayOrder);
    }

    // 영화 id로 출연진 조회
    public List<Map<String, Object>> findCastAndCrewByMovieId(Long movieId) {
        System.out.println("[LOG] 영화 출연진 조회: movieId=" + movieId);
        String sql =
            "SELECT a.id, a.name, a.profile_image_url, m.role_name, m.role_type, m.display_order " +
            "FROM movie_actors m JOIN actors a ON m.actor_id = a.id WHERE m.movie_id = ? ORDER BY m.display_order ASC";
        return jdbcTemplate.queryForList(sql, movieId);
    }

    // 출연진 id로 상세 정보
    public Map<String, Object> findActorDetail(Long actorId) {
        System.out.println("[LOG] 배우 상세정보 조회: actorId=" + actorId);
        String sql = "SELECT * FROM actors WHERE id = ?";
        return jdbcTemplate.queryForMap(sql, actorId);
    }

    // 이 배우+감독이 참여한 영화 목록
    public List<Map<String, Object>> findMoviesByActorId(Long actorId) {
        System.out.println("[LOG] 배우 참여 영화 목록 조회: actorId=" + actorId);
        String sql = """
            SELECT 
                m.id, m.title, m.poster_path, m.release_date, 
                ma.role_type, ma.role_name,
                m.rating
            FROM movie_actors ma
            JOIN movies m ON ma.movie_id = m.id
            WHERE ma.actor_id = ?
            ORDER BY m.release_date DESC, m.title ASC
        """;
        return jdbcTemplate.queryForList(sql, actorId);
    }

    // TMDB API 상세 정보 기반으로 배우 정보 업데이트
    public void updateActorDetails(Long actorId, Map<String, Object> details) {
        System.out.println("[LOG] 배우 정보 업데이트 시도: actorId=" + actorId);
        String sql = """
            UPDATE actors
            SET
                birthday = ?,
                deathday = ?,
                age = ?,
                place_of_birth = ?,
                biography = ?,
                gender = ?,
                known_for_department = ?
            WHERE id = ?
            """;

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

        System.out.println("[SUCCESS] 배우 정보 업데이트 완료: actorId=" + actorId);
    }
}
