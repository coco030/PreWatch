<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>주의 요소 관리</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    body { 
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        background-color: #f8f9fa;
    }
    .container {
        max-width: 800px;
        margin: 20px auto;
        padding: 20px;
        background-color: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
    h2 {
        font-size: 1.5em;
        margin-top: 0;
    }
    .description {
        color: #6c757d;
        margin-bottom: 20px;
    }
    .success-message {
        color: #155724;
        background-color: #d4edda;
        border: 1px solid #c3e6cb;
        padding: 10px;
        border-radius: 4px;
        margin-bottom: 20px;
    }
    form {
        margin-top: 20px;
    }
    fieldset {
        border: 1px solid #ddd;
        border-radius: 5px;
        padding: 15px;
        margin-bottom: 20px;
    }
    legend {
        font-size: 1.2em;
        font-weight: bold;
        padding: 0 10px;
        width: auto; /* legend가 길이에 맞게 조절되도록 */
    }
    .checkbox-group div {
        margin-bottom: 10px;
    }
    .checkbox-group label {
        margin-left: 8px;
        cursor: pointer;
    }
    .submit-button {
        display: block;
        width: 100%;
        padding: 12px;
        font-size: 1.1em;
        font-weight: bold;
        color: #fff;
        background-color: #0d6efd;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        transition: background-color 0.2s;
    }
    .submit-button:hover {
        background-color: #0b5ed7;
    }
    .back-link-container {
        margin-top: 20px;
        text-align: center;
    }
    .back-link {
        color: #6c757d;
        text-decoration: none;
    }
    .back-link:hover {
        text-decoration: underline;
    }

    /* 화면이 좁아질 때 폰트 크기 등을 약간 조절 */
    @media (max-width: 600px) {
        .container {
            margin: 10px;
            padding: 15px;
        }
        h2 {
            font-size: 1.3em;
        }
    }

    /* 반응형 컬럼 레이아웃 */
    /* 화면 너비가 768px 이상일 때 (태블릿/데스크탑) 적용 */
    @media (min-width: 768px) {
        form {
            display: grid;
            grid-template-columns: 1fr 1fr; /* 2개의 동일한 너비의 컬럼 생성 */
            gap: 20px; /* 컬럼과 행 사이의 간격 */
        }

        fieldset {
            /* 각 fieldset이 grid의 높이를 꽉 채우도록 설정 */
            margin-bottom: 0; 
        }

        .submit-button {
            /* 2단 컬럼 전체를 차지하도록 설정 */
            grid-column: 1 / -1;
        }
    }
</style>
</head>
<body>
    <div class="container">

        
        <h2>
            <span style="color: #6c757d;">영화:</span> ${movie.title}
        </h2>
        <p class="description">사용자에게 노출할 주의 요소를 모두 선택하고 저장하세요.</p>
    
        <c:if test="${param.update == 'success'}">
            <p class="success-message"><strong>성공!</strong> 변경사항이 성공적으로 저장되었습니다.</p>
        </c:if>

        <form action="<c:url value='/admin/warnings/${movieId}'/>" method="post">
            <c:forEach items="${allTagsGrouped}" var="entry">
                <fieldset>
                    <legend>${entry.key}</legend>
                    <div class="checkbox-group">
                        <c:forEach items="${entry.value}" var="tag">
                            <div>
                                <input type="checkbox" name="tagIds" value="${tag.id}" id="tag_${tag.id}"
                                       <c:if test="${selectedTagIds.contains(tag.id)}">checked</c:if>
                                >
                                <label for="tag_${tag.id}">${tag.sentence}</label>
                            </div>
                        </c:forEach>
                    </div>
                </fieldset>
            </c:forEach>
            <button type="submit" class="submit-button">저장하기</button>
        </form>
        
        <div class="back-link-container">
            <a href="<c:url value='/movies/${movieId}'/>" class="back-link">상세 페이지로 돌아가기</a>
        </div>
    </div>
</body>
</html>