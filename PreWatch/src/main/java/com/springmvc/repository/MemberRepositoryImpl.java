package com.springmvc.repository;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.Member;
@Repository
public class MemberRepositoryImpl implements MemberRepository {
	
	private JdbcTemplate jdbcTemplate;
	
    @Autowired
    public MemberRepositoryImpl(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }
    @Override
    public void save(Member member) {
        System.out.println("[Repository] save() 호출됨");

        String sql = "INSERT INTO member (id, password) VALUES (?, ?)";
        System.out.println("실행할 SQL: " + sql);
        System.out.println("입력값: id=" + member.getId() + ", pw=" + member.getPassword());

        jdbcTemplate.update(sql, member.getId(), member.getPassword());

        System.out.println("DB 저장 완료");
    }

	@Override
	public boolean existsById(String id) {
		String sql = "SELECT COUNT(*) FROM member WHERE id = ?";
	    Integer count = jdbcTemplate.queryForObject(sql, Integer.class, id);
	    return count != null && count > 0;
	}
	@Override
	public Member login(String id, String password) {
	    // 1. SQL 쿼리 작성
	    String sql = "SELECT * FROM member WHERE id = ? AND password = ?";
	    
	    try {
	        // 2. jdbcTemplate.queryForObject() 사용
	        // queryForObject는 결과가 정확히 1개일 때 해당 객체를 반환
	        // 결과가 없으면(0개) EmptyResultDataAccessException 예외가 발생
	        Member member = jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
	            Member m = new Member();
	            m.setId(rs.getString("id"));
	            m.setPassword(rs.getString("password"));
	            // DB에 name 컬럼이 있다면 추가: m.setName(rs.getString("name")); 없으니 추가 안 함.
	            return m;
	        }, id, password);
	        
	        return member;

	    } catch (Exception e) {
	        // 3. 쿼리 결과가 없을 경우(아이디/비밀번호 불일치) 예외가 발생하므로, null을 반환
	        return null;
	    }
 }
}