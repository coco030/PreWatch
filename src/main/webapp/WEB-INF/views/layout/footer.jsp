<%--
    파일명: footer.jsp
    설명:
        이 JSP 파일은 웹사이트의 하단(푸터) 영역을 정의합니다.

    목적:
        - 웹사이트 전체에 일관된 하단 디자인과 저작권, 연락처,등 정보를 제공하기 위함.

--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    .main-footer {
        text-align: center;
        padding: 20px;
        margin-top: 40px;
        background-color: #f8f9fa; 
        border-top: 1px solid #ddd;
        color: #6c757d; 
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
        <a href="https://github.com/qowlsgh4544/">깃허브 @qowlsgh4544 </a> |
        <a href="https://github.com/coco030">깃허브 @coco030 </a>
    </div>
    <div style="margin-top: 10px;">
        <%-- 저작권 정보 --%>
        <p>© 2025 PreWatch. All Rights Reserved.</p>
    </div>
</footer>