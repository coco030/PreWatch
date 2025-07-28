<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!-- loginModal.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!--  ==========로그인 모달===========   -->
<div class="modal fade" id="iframeLoginModal" tabindex="-1" aria-labelledby="iframeModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="iframeModalLabel">로그인을 하셔야 이용하실 수 있어요</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0" style="height: 400px;">
        <iframe src="<c:url value='/auth/login'/>"
                style="width: 100%; height: 100%; border: none;"
                title="로그인 프레임">
        </iframe>
      </div>
    </div>
  </div>
</div>
<!-- ==========로그인 모달 끝=========== -->
