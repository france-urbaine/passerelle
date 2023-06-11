CREATE TRIGGER trigger_reports_changes
  AFTER INSERT OR UPDATE OR DELETE ON reports
  FOR EACH ROW EXECUTE FUNCTION trigger_reports_changes();
