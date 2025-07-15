<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // 세션에서 loginMember 객체와 userRole 값을 가져옵니다.
    // userRole은 String 타입이므로 명확히 캐스팅합니다.
    Object loginMemberObj = session.getAttribute("loginMember");
    String userRole = (String) session.getAttribute("userRole"); // "ADMIN", "MEMBER" 또는 null
    com.springmvc.domain.Member loginMember = null;
    if (loginMemberObj != null) {
        loginMember = (com.springmvc.domain.Member) loginMemberObj;
    }
%>
<div class="header-right-wrapper">
    <%-- 로그인하지 않은 경우 (비회원) --%>
    <% if (loginMember == null) { %>    
        <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
        <a href="${pageContext.request.contextPath}/auth/login">로그인</a>
    <% } 
    // 로그인한 경우 (회원 또는 관리자)
    else { %>
        <%-- 현재 로그인된 사용자가 관리자인 경우 --%>
        <c:if test="<%= userRole != null && userRole.equals(\"ADMIN\") %>">
            <%-- 관리자에게만 보이는 링크 (예시: 관리자 대시보드) --%>
            <a href="${pageContext.request.contextPath}/admin/dashboard">관리자 대시보드</a> |
            <a href="${pageContext.request.contextPath}/auth/logout">로그아웃</a>
        </c:if>

        <%-- 현재 로그인된 사용자가 일반 회원인 경우 --%>
        <c:if test="<%= userRole != null && userRole.equals(\"MEMBER\") %>">
            <a href="${pageContext.request.contextPath}/member/mypage">나의 영화 기록</a> |
            <a href="${pageContext.request.contextPath}/member/editForm">회원 정보 수정</a> |
            <a href="${pageContext.request.contextPath}/auth/logout">로그아웃</a>
        </c:if>

        <%-- 로그인된 사용자의 역할과 ID를 표시 (관리자, 회원 공통) --%>
        <span style="margin-left: 10px; color: #555;">
            <c:if test="<%= userRole != null && userRole.equals(\"ADMIN\") %>">관리자</c:if>
            <c:if test="<%= userRole != null && userRole.equals(\"MEMBER\") %>">회원</c:if>
            (<%= loginMember.getId() %>)님
        </span>
    <% } %>
</div>