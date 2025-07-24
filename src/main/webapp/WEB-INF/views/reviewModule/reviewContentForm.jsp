<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 영화 ID -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="memberId" value="${loginMember.id}" />
</c:if>

<!-- review-section은 항상 출력됨 -->
<div id="review-section" class="my-4">
    <h5>내 리뷰</h5>

    <!-- 로그인 여부 확인 -->
    <c:if test="${not empty loginMember}">
        <!-- 작성창 (내 리뷰가 없을 때) -->
        <div id="reviewWriteBox" <c:if test="${not empty myReview.reviewContent}">style="display:none;"</c:if>>
            <textarea id="reviewContentInput" rows="4" cols="60"
                      placeholder="리뷰를 작성해주세요."></textarea><br>
            <button id="saveReviewContentBtn">리뷰 저장</button>
        </div>

        <!-- 출력창 (내 리뷰가 있을 때) -->
        <div id="reviewDisplayBox" <c:if test="${empty myReview.reviewContent}">style="display:none;"</c:if>>
            <strong>리뷰 :</strong>
            <div id="reviewContentBox">
                <span id="reviewText">${fn:escapeXml(myReview.reviewContent)}</span>
            </div>
            <button id="editReviewBtn">수정</button>
            <button id="deleteReviewBtn">삭제</button>
        </div>
    </c:if>

    <c:if test="${empty loginMember}">
        <!-- 로그인하지 않은 경우에도 항상 뜨는 안내 메시지 -->
        <div style="color: gray; margin-top: 8px;">
            리뷰를 작성하시려면 로그인해주세요.
        </div>
    </c:if>
</div>


<!-- JS -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const content = "${fn:escapeXml(myReview.reviewContent)}";
    const input = document.getElementById("reviewContentInput");
    if (input && content.trim() !== "") {
        input.value = content;
    }

    const saveBtn = document.getElementById("saveReviewContentBtn");
    const editBtn = document.getElementById("editReviewBtn");
    const deleteBtn = document.getElementById("deleteReviewBtn");

    // 저장
    if (saveBtn) {
        saveBtn.addEventListener("click", function () {
            const content = document.getElementById("reviewContentInput").value.trim();
            const movieId = document.getElementById("movieId").value;

            if (content === "") {
                alert("리뷰 내용을 입력해주세요.");
                return;
            }

            const formData = new URLSearchParams();
            formData.append("movieId", movieId);
            formData.append("reviewContent", content);

            fetch("${pageContext.request.contextPath}/review/saveContent", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert("리뷰가 저장되었습니다.");
                    document.getElementById("reviewText").textContent = content;
                    document.getElementById("reviewWriteBox").style.display = "none";
                    document.getElementById("reviewDisplayBox").style.display = "block";
                } else {
                    alert(data.message || "저장 실패");
                }
            });
        });
    }

    // 수정
    if (editBtn) {
        editBtn.addEventListener("click", function () {
            document.getElementById("reviewWriteBox").style.display = "block";
            document.getElementById("reviewDisplayBox").style.display = "none";
        });
    }

    // 삭제
    if (deleteBtn) {
        deleteBtn.addEventListener("click", function () {
            if (!confirm("정말 리뷰를 삭제하시겠습니까?")) return;

            const movieId = document.getElementById("movieId").value;

            fetch("${pageContext.request.contextPath}/review/deleteReview", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ movieId })
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert("삭제되었습니다.");
                    document.getElementById("reviewWriteBox").style.display = "block";
                    document.getElementById("reviewDisplayBox").style.display = "none";
                    document.getElementById("reviewContentInput").value = "";
                } else {
                    alert(data.message || "삭제 실패");
                }
            });
        });
    }
});
</script>
