package com.springmvc.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.WarningTag;

@Repository
public class WarningTagRepositoryImpl implements WarningTagRepository  {

	private static final Logger logger = LoggerFactory.getLogger(WarningTagRepositoryImpl.class);
	private static final String CREATE_WARNING_TAGS_SQL =
		"CREATE TABLE IF NOT EXISTS warning_tags ("
			+ "id BIGINT AUTO_INCREMENT PRIMARY KEY, "
			+ "category VARCHAR(50) NOT NULL, "
			+ "sentence VARCHAR(255) NOT NULL UNIQUE, "
			+ "sort_order INT DEFAULT 0, "
			+ "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
			+ ")";
	private static final String CREATE_MOVIE_WARNING_TAGS_SQL =
		"CREATE TABLE IF NOT EXISTS movie_warning_tags ("
			+ "movie_id BIGINT NOT NULL, "
			+ "warning_tag_id BIGINT NOT NULL, "
			+ "PRIMARY KEY (movie_id, warning_tag_id), "
			+ "FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE, "
			+ "FOREIGN KEY (warning_tag_id) REFERENCES warning_tags(id) ON DELETE CASCADE"
			+ ")";
	private static final String SELECT_ALL_SQL = "SELECT * FROM warning_tags ORDER BY category, sort_order, id";
	private static final DefaultWarningTag[] DEFAULT_WARNING_TAGS = {
		new DefaultWarningTag("공포", "갑작스러운 놀람 장면이 포함되어 있습니다.", 10),
		new DefaultWarningTag("공포", "지속적인 긴장감이나 불안감을 유발할 수 있습니다.", 20),
		new DefaultWarningTag("공포", "귀신, 괴물 또는 초자연적 존재가 등장합니다.", 30),
		new DefaultWarningTag("공포", "어두운 분위기와 음향 효과로 공포감이 강할 수 있습니다.", 40),
		new DefaultWarningTag("잔인성", "상처나 신체 훼손 묘사가 포함되어 있습니다.", 10),
		new DefaultWarningTag("잔인성", "피가 나오는 장면이 포함되어 있습니다.", 20),
		new DefaultWarningTag("잔인성", "잔혹한 사망 장면이 포함되어 있습니다.", 30),
		new DefaultWarningTag("잔인성", "혐오감을 줄 수 있는 벌레, 시체, 훼손 묘사가 포함되어 있습니다.", 40),
		new DefaultWarningTag("폭력성", "싸움, 폭행 또는 물리적 폭력 장면이 포함되어 있습니다.", 10),
		new DefaultWarningTag("폭력성", "고문이나 위협 장면이 포함되어 있습니다.", 20),
		new DefaultWarningTag("폭력성", "총기나 흉기 사용 장면이 포함되어 있습니다.", 30),
		new DefaultWarningTag("폭력성", "아동 또는 약자를 향한 폭력 장면이 포함되어 있습니다.", 40),
		new DefaultWarningTag("선정성", "성적 대사나 암시가 포함되어 있습니다.", 10),
		new DefaultWarningTag("선정성", "노출 장면이 포함되어 있습니다.", 20),
		new DefaultWarningTag("선정성", "성적 폭력 또는 강압적 상황이 암시될 수 있습니다.", 30),
		new DefaultWarningTag("선정성", "성적 상황화로 불쾌감을 줄 수 있는 장면이 포함되어 있습니다.", 40),
		new DefaultWarningTag("약물", "음주 또는 흡연 장면이 포함되어 있습니다.", 10),
		new DefaultWarningTag("약물", "약물 사용 또는 중독 관련 묘사가 포함되어 있습니다.", 20),
		new DefaultWarningTag("동물", "동물이 다치거나 위험에 처하는 장면이 포함되어 있습니다.", 10),
		new DefaultWarningTag("동물", "동물 사망 또는 사망 암시가 포함되어 있습니다.", 20),
		new DefaultWarningTag("기타", "자해 또는 자살 관련 묘사가 포함되어 있습니다.", 10),
		new DefaultWarningTag("기타", "차별적 표현이나 혐오 표현이 포함되어 있습니다.", 20)
	};

	@Autowired
    private DataSource dataSource; // DB 커넥션을 얻기 위해 Spring이 주입해 줌
	private volatile boolean schemaChecked;
	
	  // [관리자용] 모든 주의 요소 문장들을 가져오기
    @Override
    public List<WarningTag> getAllWarningTags() {
        ensureWarningTables();
        List<WarningTag> tags = findAllWarningTags();
        if (tags.isEmpty()) {
            seedDefaultWarningTags();
            tags = findAllWarningTags();
        }
        return tags;
    }

    private List<WarningTag> findAllWarningTags() {
        List<WarningTag> tags = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = dataSource.getConnection();
            pstmt = conn.prepareStatement(SELECT_ALL_SQL);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                tags.add(mapWarningTag(rs));
            }
        } catch (SQLException e) {
            logger.warn("주의 요소 목록을 조회하지 못했습니다.", e);
        } finally {
            // 리소스 정리 (매우 중요!)
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return tags;
    }

    private void seedDefaultWarningTags() {
        String SQL = "INSERT IGNORE INTO warning_tags (category, sentence, sort_order) VALUES (?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {

            for (DefaultWarningTag tag : DEFAULT_WARNING_TAGS) {
                pstmt.setString(1, tag.category);
                pstmt.setString(2, tag.sentence);
                pstmt.setInt(3, tag.sortOrder);
                pstmt.addBatch();
            }

            int insertedCount = 0;
            int[] results = pstmt.executeBatch();
            for (int result : results) {
                if (result > 0) {
                    insertedCount += result;
                }
            }
            logger.info("주의 요소 기본 데이터 {}개를 보강했습니다.", insertedCount);
        } catch (SQLException e) {
            logger.warn("주의 요소 기본 데이터를 보강하지 못했습니다.", e);
        }
    }

    private WarningTag mapWarningTag(ResultSet rs) throws SQLException {
        WarningTag tag = new WarningTag();
        tag.setId(rs.getLong("id"));
        tag.setCategory(rs.getString("category"));
        tag.setSentence(rs.getString("sentence"));
        tag.setSortOrder(rs.getInt("sort_order"));
        tag.setCreatedAt(rs.getObject("created_at", LocalDateTime.class));
        return tag;
    }

    // [사용자용] 특정 영화에 해당하는 주의 요소 문장들만 가져오기
    @Override
    public List<WarningTag> getWarningTagsByMovieId(long movieId) {
        ensureWarningTables();
        // movie_warning_tags와 warning_tags 테이블을 JOIN하여 데이터를 가져옴
        String SQL = "SELECT wt.* FROM warning_tags wt " +
                     "JOIN movie_warning_tags mwt ON wt.id = mwt.warning_tag_id " +
                     "WHERE mwt.movie_id = ? " +
                     "ORDER BY wt.category, wt.sort_order";
        List<WarningTag> tags = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = dataSource.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setLong(1, movieId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                tags.add(mapWarningTag(rs));
            }
        } catch (SQLException e) {
            logger.warn("영화 ID {}의 주의 요소 목록을 조회하지 못했습니다.", movieId, e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return tags;
    }

    // [관리자용] 특정 영화의 기존 주의 요소 매핑 정보 모두 삭제
    @Override
    public void deleteWarningTagsByMovieId(long movieId) {
        ensureWarningTables();
        String SQL = "DELETE FROM movie_warning_tags WHERE movie_id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            
            pstmt.setLong(1, movieId);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            logger.warn("영화 ID {}의 주의 요소 매핑을 삭제하지 못했습니다.", movieId, e);
        }
    }

    // [관리자용] 특정 영화에 새로운 주의 요소들 추가
    @Override
    public void addWarningTagsToMovie(long movieId, List<Long> warningTagIds) {
        ensureWarningTables();
        String SQL = "INSERT INTO movie_warning_tags (movie_id, warning_tag_id) VALUES (?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {

            for (Long tagId : warningTagIds) {
                pstmt.setLong(1, movieId);
                pstmt.setLong(2, tagId);
                pstmt.addBatch(); // 여러 INSERT를 한번에 처리하기 위해 배치에 추가
            }
            pstmt.executeBatch(); // 배치 실행

        } catch (SQLException e) {
            logger.warn("영화 ID {}의 주의 요소 매핑을 추가하지 못했습니다.", movieId, e);
        }
    }

    private void ensureWarningTables() {
        if (schemaChecked) {
            return;
        }

        synchronized (this) {
            if (schemaChecked) {
                return;
            }

            try (Connection conn = dataSource.getConnection();
                 Statement stmt = conn.createStatement()) {
                stmt.executeUpdate(CREATE_WARNING_TAGS_SQL);
                stmt.executeUpdate(CREATE_MOVIE_WARNING_TAGS_SQL);
                schemaChecked = true;
            } catch (SQLException e) {
                logger.warn("주의 요소 테이블을 확인하거나 생성하지 못했습니다.", e);
            }
        }
    }

    private static class DefaultWarningTag {
        private final String category;
        private final String sentence;
        private final int sortOrder;

        private DefaultWarningTag(String category, String sentence, int sortOrder) {
            this.category = category;
            this.sentence = sentence;
            this.sortOrder = sortOrder;
        }
    }

}




