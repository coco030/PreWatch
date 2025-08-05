package com.springmvc.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.WarningTag;

@Repository
public class WarningTagRepositoryImpl implements WarningTagRepository  {

	@Autowired
    private DataSource dataSource; // DB 커넥션을 얻기 위해 Spring이 주입해 줌
	
	  // [관리자용] 모든 주의 요소 문장들을 가져오기
    @Override
    public List<WarningTag> getAllWarningTags() {
        String SQL = "SELECT * FROM warning_tags ORDER BY category, sort_order";
        List<WarningTag> tags = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = dataSource.getConnection();
            pstmt = conn.prepareStatement(SQL);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                WarningTag tag = new WarningTag();
                tag.setId(rs.getLong("id"));
                tag.setCategory(rs.getString("category"));
                tag.setSentence(rs.getString("sentence"));
                tag.setSortOrder(rs.getInt("sort_order"));
                tag.setCreatedAt(rs.getObject("created_at", LocalDateTime.class));
                tags.add(tag);
            }
        } catch (SQLException e) {
            e.printStackTrace(); // 실제 서비스에서는 로깅으로 대체해야 함
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

    // [사용자용] 특정 영화에 해당하는 주의 요소 문장들만 가져오기
    @Override
    public List<WarningTag> getWarningTagsByMovieId(long movieId) {
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
                WarningTag tag = new WarningTag();
                tag.setId(rs.getLong("id"));
                tag.setCategory(rs.getString("category"));
                tag.setSentence(rs.getString("sentence"));
                tags.add(tag);
            }
        } catch (SQLException e) {
            e.printStackTrace();
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
        String SQL = "DELETE FROM movie_warning_tags WHERE movie_id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            
            pstmt.setLong(1, movieId);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // [관리자용] 특정 영화에 새로운 주의 요소들 추가
    @Override
    public void addWarningTagsToMovie(long movieId, List<Long> warningTagIds) {
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
            e.printStackTrace();
        }
    }

}
