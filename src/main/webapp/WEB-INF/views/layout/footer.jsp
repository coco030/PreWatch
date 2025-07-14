<%-- /views/layout/footer.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    .main-footer {
        text-align: center;
        padding: 20px;
        margin-top: 40px;
        background-color: #f8f9fa; /* 밝은 회색 배경 */
        border-top: 1px solid #ddd;
        color: #6c757d; /* 회색 계열 텍스트 색상 */
        font-size: 0.9em;
    }
    .main-footer a {
        color: #495057;
        text-decoration: none;
        margin: 0 10px;
    }
    .main-footer a:hover {
        text-decoration: underline;
    }
</style>

<footer class="main-footer">
    <div>
        <a href="#">프로젝트 기간 : 25.07.08~25.07.25</a> |
        <a href="#">문의</a> |
        <a href="#">확인</a>
    </div>
    <div style="margin-top: 10px;">
        <%-- 저작권 정보 --%>
        <p>© 2024 PreWatch. All Rights Reserved.</p>
    </div>
</footer>