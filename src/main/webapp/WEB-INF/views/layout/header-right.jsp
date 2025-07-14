<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    Object loginMember = session.getAttribute("loginMember");
%>
<div class="header-right-wrapper">
<% if (loginMember == null) { %>    
    <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
    <a href="${pageContext.request.contextPath}/login">로그인</a>
<% } else { 
       com.springmvc.domain.Member member = (com.springmvc.domain.Member) loginMember;
%>
    <a href="${pageContext.request.contextPath}/member/mypage">나의 영화 기록</a>
    <a href="${pageContext.request.contextPath}/member/editForm">회원 정보 수정</a>
    <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
<% } %>
</div>