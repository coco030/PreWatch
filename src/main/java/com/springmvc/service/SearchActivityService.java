package com.springmvc.service;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SearchActivityService {

    private static final int MAX_KEYWORD_LENGTH = 40;
    private static final int RECENT_KEYWORD_LIMIT = 8;
    private static final String CREATE_SEARCH_ACTIVITY_SQL = """
        CREATE TABLE IF NOT EXISTS search_activity (
            keyword VARCHAR(80) PRIMARY KEY,
            search_count INT NOT NULL DEFAULT 1,
            last_searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
        """;

    private final JdbcTemplate jdbcTemplate;
    private volatile boolean schemaChecked;

    public SearchActivityService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional
    public void record(String keyword) {
        String normalizedKeyword = normalize(keyword);
        if (normalizedKeyword.isEmpty()) {
            return;
        }

        ensureSearchActivityTable();
        String sql = """
            INSERT INTO search_activity (keyword, search_count, last_searched_at)
            VALUES (?, 1, CURRENT_TIMESTAMP)
            ON DUPLICATE KEY UPDATE
                search_count = search_count + 1,
                last_searched_at = CURRENT_TIMESTAMP
            """;
        jdbcTemplate.update(sql, normalizedKeyword);
    }

    @Transactional(readOnly = true)
    public List<String> getRecentKeywords() {
        ensureSearchActivityTable();
        // 홈 노출용 검색어. 현재는 전체 최근순.
        String sql = """
            SELECT keyword
            FROM search_activity
            ORDER BY last_searched_at DESC
            LIMIT ?
            """;
        return jdbcTemplate.queryForList(sql, String.class, RECENT_KEYWORD_LIMIT);
    }

    private void ensureSearchActivityTable() {
        if (schemaChecked) {
            return;
        }

        synchronized (this) {
            if (schemaChecked) {
                return;
            }

            jdbcTemplate.execute(CREATE_SEARCH_ACTIVITY_SQL);
            schemaChecked = true;
        }
    }

    private String normalize(String keyword) {
        if (keyword == null) {
            return "";
        }

        String normalizedKeyword = keyword.trim().replaceAll("\\s+", " ");
        if (normalizedKeyword.length() > MAX_KEYWORD_LENGTH) {
            return normalizedKeyword.substring(0, MAX_KEYWORD_LENGTH);
        }
        return normalizedKeyword;
    }
}
