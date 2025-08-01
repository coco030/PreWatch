package com.springmvc.repository;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.sql.DataSource; // DB 연결 풀 관리

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.Member; 

// MemberRepositoryImpl 클래스: MemberRepository 인터페이스 구현.
// 목적: JDBC와 JdbcTemplate을 사용하여 실제 'member' 테이블에 접근.
@Repository // Spring 빈으로 등록
public class MemberRepositoryImpl implements MemberRepository {

	private JdbcTemplate jdbcTemplate; // DB 작업 수행 객체

	 @Autowired
	    private NamedParameterJdbcTemplate namedParameterJdbcTemplate;
	 
	// 생성자를 통한 DataSource 주입: JdbcTemplate 초기화
	@Autowired
    public MemberRepositoryImpl(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    // save 메서드: Member 객체를 'member' 테이블에 삽입.
    // 목적: 회원가입 시 새 회원 정보 저장.
    @Override
    public void save(Member member) {
        System.out.println("회원가입 저장 save로 진입 : " + member);
        String sql = "INSERT INTO member (id, password, status, role) VALUES (?, ?, ?, ?)"; // role 컬럼 포함
        System.out.println("실행할 SQL: " + sql);
        System.out.println("입력값: id=" + member.getId() + ", pw=" + member.getPassword() + ", role=" + member.getRole());

        // Member 객체의 role 사용, 없으면 'MEMBER' 기본값 설정
        String roleToSave = (member.getRole() != null && !member.getRole().isEmpty()) ? member.getRole() : "MEMBER";

        jdbcTemplate.update(sql, member.getId(), member.getPassword(), "ACTIVE", roleToSave); // INSERT 쿼리 실행
        System.out.println("DB 저장 완료");
    }

    // existsById 메서드: 주어진 ID를 가진 회원이 DB에 존재하는지 확인.
    // 목적: 회원가입 시 아이디 중복 검사.
    @Override
    public boolean existsById(String id) {
        String sql = "SELECT COUNT(*) FROM member WHERE id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, id); // COUNT 값 조회
        return count != null && count > 0; // 0보다 크면 존재
    }

    // login 메서드: ID/PW가 일치하고 'ACTIVE' 상태인 회원 정보 조회.
    // 목적: 로그인 시 사용자 인증.
    @Override
    public Member login(String id, String password) {
        String sql = "SELECT id, password, status, role FROM member WHERE id = ? AND password = ? AND status = 'ACTIVE'";
        try {
            // 단일 객체 조회 및 ResultSet 매핑 (role 포함)
            Member member = jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                Member m = new Member();
                m.setId(rs.getString("id"));
                m.setPassword(rs.getString("password"));
                m.setRole(rs.getString("role"));
                return m;
            }, id, password);
            return member; // 로그인 성공 시 Member 객체 반환
        } catch (EmptyResultDataAccessException e) {
            System.out.println("로그인 실패: 일치하는 회원 정보 없음.");
            return null; // 결과 없을 때 null 반환
        } catch (Exception e) {
            System.err.println("로그인 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            return null; // 오류 발생 시 null 반환
        }
    }

    // updatePassword 메서드: 특정 회원의 비밀번호를 새 비밀번호로 업데이트.
    // 목적: 비밀번호 변경 기능.
    @Override
    public void updatePassword(String id, String pw) {
        System.out.println("[Repository] updatePassword() 진입");
        System.out.println("[Repository] 실행할 SQL: UPDATE member SET password = ? WHERE id = ?");
        System.out.println("[Repository] 파라미터 id = " + id + ", pw = " + pw);
        String sql = "UPDATE member SET password = ? WHERE id = ?";

        int result = jdbcTemplate.update(sql, pw, id); // UPDATE 쿼리 실행

        System.out.println("[Repository] SQL 실행 결과: " + result + " rows updated");
        if (result == 0) {
            System.out.println("[Repository] ※ 주의: 해당 ID로 수정된 행 없음 (ID 불일치 가능)");
        } else {
            System.out.println("[Repository] 비밀번호 성공적으로 변경됨");
        }
    }

    // deactivate 메서드: 특정 회원의 'status'를 'INACTIVE'로 변경.
    // 목적: 회원 탈퇴 (논리적 삭제) 기능. 데이터 유지 목적.
    @Override
    public void deactivate(String id) {
        System.out.println("회원을 탈퇴(정확히는 비활성화)하기 위한 정보변경 repository 진입");
        String sql = "UPDATE member SET status = 'INACTIVE' WHERE id = ?";
        int result = jdbcTemplate.update(sql, id); // UPDATE 쿼리 실행

        System.out.println("실제 수정된 행 수: " + result);
    }


	
	@Override
    public Member findById(String id) {
        String sql = "SELECT * FROM member WHERE id = :id";
        try {
            Map<String, String> params = Collections.singletonMap("id", id);
            return namedParameterJdbcTemplate.queryForObject(sql, params, new BeanPropertyRowMapper<>(Member.class));
        } catch (EmptyResultDataAccessException e) {
            // 해당 ID의 회원이 없을 경우 예외가 발생하므로, null을 반환하도록 처리
            return null; 
        }
    }
	
	@Override
	public void updateTasteProfile(String memberId, String title, String report, double score) {
	    String sql = "UPDATE member SET taste_title = :title, taste_report = :report, taste_anomaly_score = :score WHERE id = :memberId";
	    
	    Map<String, Object> params = new HashMap<>();
	    params.put("title", title);
	    params.put("report", report);
	    params.put("score", score);
	    params.put("memberId", memberId);
	    
	    namedParameterJdbcTemplate.update(sql, params);
	}
}