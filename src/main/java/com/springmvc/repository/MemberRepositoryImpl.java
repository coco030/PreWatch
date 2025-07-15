package com.springmvc.repository;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.Member;
import org.springframework.dao.EmptyResultDataAccessException; // 이 임포트 추가

@Repository
public class MemberRepositoryImpl implements MemberRepository {
	
	private JdbcTemplate jdbcTemplate;
	
	@Autowired
    public MemberRepositoryImpl(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }
    
    @Override
    public void save(Member member) {
        System.out.println("회원가입 저장 save로 진입 : " + member);
        // ⭐ role 컬럼 추가 시 INSERT 문에도 role 값을 넣어줘야 합니다.
        // 회원가입 시 기본 역할(예: 'MEMBER')을 설정
        String sql = "INSERT INTO member (id, password, status, role) VALUES (?, ?, ?, ?)";
        
        System.out.println("실행할 SQL: " + sql);
        System.out.println("입력값: id=" + member.getId() + ", pw=" + member.getPassword() + ", role=" + member.getRole());
        
        // Member 객체에 role이 없다면 기본값 'MEMBER'를 사용 (서비스 계층에서 설정하는 것이 더 좋음)
        String roleToSave = (member.getRole() != null && !member.getRole().isEmpty()) ? member.getRole() : "MEMBER";
        
        jdbcTemplate.update(sql, member.getId(), member.getPassword(), "ACTIVE", roleToSave);
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
        // 1. SQL 쿼리 작성 (SELECT *는 모든 컬럼을 가져오지만, 매핑 시 주의)
        String sql = "SELECT id, password, status, role FROM member WHERE id = ? AND password = ? AND status = 'ACTIVE'"; // ⭐ SELECT * 대신 컬럼 명시 추천
        try {
            // 2. jdbcTemplate.queryForObject() 사용
            Member member = jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                Member m = new Member();
                m.setId(rs.getString("id"));
                m.setPassword(rs.getString("password"));
                // DB에 name 컬럼이 있다면 추가: m.setName(rs.getString("name")); 없으니 추가 안 함.
                m.setRole(rs.getString("role")); // ⭐⭐ 이 부분이 추가되어야 합니다! ⭐⭐
                return m;
            }, id, password);      
            return member;
        } catch (EmptyResultDataAccessException e) { // 결과가 없을 때 발생하는 예외를 명확히 지정
            // 3. 쿼리 결과가 없을 경우(아이디/비밀번호 불일치) 예외가 발생하므로, null을 반환
            System.out.println("로그인 실패: 일치하는 회원 정보 없음.");
            return null;
        } catch (Exception e) {
            System.err.println("로그인 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    @Override
    public void updatePassword(String id, String pw) {
        System.out.println("[Repository] updatePassword() 진입");
        System.out.println("[Repository] 실행할 SQL: UPDATE member SET password = ? WHERE id = ?");
        System.out.println("[Repository] 파라미터 id = " + id + ", pw = " + pw);
        String sql = "UPDATE member SET password = ? WHERE id = ?";
        
        int result = jdbcTemplate.update(sql, pw, id);

        System.out.println("[Repository] SQL 실행 결과: " + result + " rows updated");

        if (result == 0) {
            System.out.println("[Repository] ※ 주의: 해당 ID로 수정된 행 없음 (ID 불일치 가능)");
        } else {
            System.out.println("[Repository] 비밀번호 성공적으로 변경됨");
        }
    }
    
    @Override
    public void deactivate(String id) {
        System.out.println("회원을 탈퇴(정확히는 비활성화)하기 위한 정보변경 repository 진입");
        String sql = "UPDATE member SET status = 'INACTIVE' WHERE id = ?";
        int result = jdbcTemplate.update(sql, id);

        System.out.println("실제 수정된 행 수: " + result);
    }
}