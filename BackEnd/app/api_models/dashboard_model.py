from flask import Blueprint, request, jsonify
from functools import wraps
from app.services.reward_service import (
	PointService, 
	RewardService, 
	DailyProgressService
)
from backEnd.app.models.point_model import Point
from backEnd.app.models.reward_model import Reward
from backEnd.app.models.daily_feedback_model import DailyFeedback

dashboard_bp = Blueprint('dashboard', __name__, url_prefix='/api/dashboard')


# ============ POINTS ENDPOINTS ============
@dashboard_bp.route('/points/daily/<child_id>', methods=['GET'])
def get_daily_points(child_id):
	"""Get daily points summary for a child"""
	try:
		result = PointService.get_daily_points_summary(child_id)
		return jsonify({
			"success": True,
			"data": result
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/points/weekly/<child_id>', methods=['GET'])
def get_weekly_points(child_id):
	"""Get weekly points summary for a child"""
	try:
		result = PointService.get_weekly_points_summary(child_id)
		return jsonify({
			"success": True,
			"data": result
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/points/history/<child_id>', methods=['GET'])
def get_points_history(child_id):
	"""Get points history for a child"""
	try:
		days = request.args.get('days', default=30, type=int)
		result = PointService.get_points_history(child_id, days)
		return jsonify({
			"success": True,
			"data": result
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/points/add', methods=['POST'])
def add_points():
	"""Add points to a child's account"""
	try:
		data = request.get_json()
		result = PointService.add_points(
			child_id=data.get('child_id'),
			points_earned=data.get('points_earned'),
			task_id=data.get('task_id'),
			parent_id=data.get('parent_id'),
			notes=data.get('notes'),
			points_set_by_parent=data.get('points_set_by_parent', 5)
		)
		status_code = 201 if result.get('success') else 400
		return jsonify(result), status_code
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/points/update/<point_id>', methods=['PUT'])
def update_point(point_id):
	"""Update a specific point value"""
	try:
		data = request.get_json()
		result = PointService.update_point_value(
			point_id,
			data.get('new_points_value')
		)
		return jsonify(result), 200 if result.get('success') else 400
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


# ============ REWARDS ENDPOINTS ============

@dashboard_bp.route('/rewards/week/<child_id>', methods=['GET'])
def get_week_rewards(child_id):
	"""Get all rewards for current week"""
	try:
		result = RewardService.get_week_rewards(child_id)
		return jsonify({
			"success": True,
			"data": result
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/rewards/active/<child_id>', methods=['GET'])
def get_active_rewards(child_id):
	"""Get only active (on) rewards for current week"""
	try:
		result = RewardService.get_active_rewards(child_id)
		return jsonify({
			"success": True,
			"data": result
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/rewards/toggle/<reward_id>', methods=['PUT'])
def toggle_reward(reward_id):
	"""Toggle a reward status (on/off)"""
	try:
		result = RewardService.toggle_reward_status(reward_id)
		return jsonify(result), 200 if result.get('success') else 400
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/rewards/create-weekly/<child_id>/<parent_id>', methods=['POST'])
def create_weekly_rewards(child_id, parent_id):
	"""Create default weekly rewards for a child"""
	try:
		result = RewardService.create_week_rewards(child_id, parent_id)
		status_code = 201 if result.get('success') else 400
		return jsonify(result), status_code
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


# ============ DAILY PROGRESS ENDPOINTS ============

@dashboard_bp.route('/progress/daily/<child_id>', methods=['GET'])
def get_daily_progress(child_id):
	"""Get daily progress summary - تقدمك اليومي"""
	try:
		date = request.args.get('date', default=None)
		result = DailyProgressService.get_daily_progress(child_id, date)
		return jsonify({
			"success": True,
			"data": result
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/progress/chart/<child_id>', methods=['GET'])
def get_progress_chart(child_id):
	"""Get progress chart data - رسم بياني تقدمك اليومي"""
	try:
		days = request.args.get('days', default=30, type=int)
		result = DailyProgressService.get_progress_chart_data(child_id, days)
		return jsonify({
			"success": True,
			"chart_title": result['chart_title'],
			"data": result
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/progress/weekly-report/<child_id>', methods=['GET'])
def get_weekly_report(child_id):
	"""Get complete weekly progress report"""
	try:
		result = DailyProgressService.get_weekly_progress_report(child_id)
		return jsonify({
			"success": True,
			"data": result
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


@dashboard_bp.route('/feedback/daily/<child_id>', methods=['GET'])
def get_daily_feedback(child_id):
	"""Get daily feedback summary"""
	try:
		from datetime import datetime
		date = request.args.get('date', default=datetime.now().date())
		
		feedback = DailyFeedback.query.filter_by(
			child_id=child_id,
			feedback_date=date
		).first()
		
		if feedback:
			return jsonify({
				"success": True,
				"data": feedback.to_dict()
			}), 200
		else:
			return jsonify({
				"success": False,
				"message": "لا يوجد فيدباك ليوم اليوم"
			}), 404
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500


# ============ SUMMARY ENDPOINTS ============

@dashboard_bp.route('/summary/<child_id>', methods=['GET'])
def get_dashboard_summary(child_id):
	"""Get complete dashboard summary for a child"""
	try:
		# Get today's progress
		daily_progress = DailyProgressService.get_daily_progress(child_id)
		
		# Get weekly summary
		weekly_points = PointService.get_weekly_points_summary(child_id)
		
		# Get rewards
		week_rewards = RewardService.get_week_rewards(child_id)
		
		return jsonify({
			"success": True,
			"data": {
				"today_progress": daily_progress,
				"weekly_points": weekly_points,
				"rewards": week_rewards
			}
		}), 200
	except Exception as e:
		return jsonify({
			"success": False,
			"message": str(e)
		}), 500
