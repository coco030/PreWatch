<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
// 세션에서 loginMember 객체와 userRole 값을 가져옴.
Object loginMemberObj = session.getAttribute("loginMember");
String userRole = (String) session.getAttribute("userRole");
com.springmvc.domain.Member loginMember = null;
if (loginMemberObj != null) {
    loginMember = (com.springmvc.domain.Member) loginMemberObj;
}
%>

<div class="header-right-wrapper">
    <% if (loginMember == null) { %>
        <!-- 비로그인 상태 -->
        <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
        <a href="${pageContext.request.contextPath}/auth/login">로그인</a>
        
    <% } else { %>
        <!-- 로그인 상태 -->
        <c:if test="${userRole != null && userRole eq 'ADMIN'}">
            <!-- 관리자 메뉴 -->
            <a href="${pageContext.request.contextPath}/movies">관리자 대시보드</a>
            <a href="${pageContext.request.contextPath}/auth/logout">로그아웃</a>
            <span>관리자 (${loginMember.id})님</span>
        </c:if>
        
        <c:if test="${userRole != null && userRole eq 'MEMBER'}">
            <!-- 회원 메뉴 -->
            <a href="${pageContext.request.contextPath}/member/wishlist">보고 싶어요</a>
            <a href="${pageContext.request.contextPath}/member/mypage">나의 기록</a>
            <a href="${pageContext.request.contextPath}/member/editForm">정보수정</a>
            <a href="${pageContext.request.contextPath}/auth/logout">로그아웃</a>
            <span>회원 (${loginMember.id})님</span>
        </c:if>
    <% } %>
</div>