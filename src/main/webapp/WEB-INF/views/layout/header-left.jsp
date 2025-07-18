<%--
    파일명: header-left.jsp
    설명:
        이 JSP 파일은 웹사이트 헤더의 왼쪽 영역을 정의합니다.
        웹사이트의 로고나 브랜드 이름을 포함하며, 클릭 시 메인 페이지로 이동하는 링크 역할을 합니다.

    목적:
        - 웹사이트의 브랜드를 표시하고, 사용자가 어떤 페이지에 있든 메인 페이지로 빠르게 돌아갈 수 있는 홈 링크를 제공하기 위해.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="header-left">
    <a href="${pageContext.request.contextPath}/">PreWatch</a>
    <!-- 홈페이지 주소로 이동 -->
</div>